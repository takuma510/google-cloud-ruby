# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/bigquery"
require "google/cloud/storage"

# Create shared bigquery object so we don't create new for each test
$bigquery = Google::Cloud::Bigquery.new retries: 10

# Create shared storage object so we don't create new for each test
$storage = Google::Cloud::Storage.new

# create prefix for names of datasets and tables
require "time"
require "securerandom"
t = Time.now.utc.iso8601.gsub ":", "_"
$prefix = "gcloud_ruby_acceptance_#{t}_#{SecureRandom.hex(4)}".downcase.gsub "-", "_"

def safe_gcs_execute retries: 20, delay: 2
  current_retries = 0
  loop do
    begin
      return yield
    rescue Google::Cloud::ResourceExhaustedError
      raise unless current_retries >= retries

      sleep delay
      current_retries += 1
    end
  end
end

$bucket = safe_gcs_execute { $storage.create_bucket "#{$prefix}_bucket" }

module Acceptance
  ##
  # Test class for running against a BigQuery instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :bigquery to describe:
  #
  #   describe "My BigQuery Test", :bigquery do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class BigqueryTest < Minitest::Test
    attr_accessor :bigquery
    attr_accessor :prefix
    attr_accessor :storage
    attr_accessor :bucket

    ##
    # Setup project based on available ENV variables
    def setup
      @bigquery = $bigquery
      @prefix = $prefix
      @storage = $storage
      @bucket = $bucket

      refute_nil @bigquery, "You do not have an active bigquery to run the tests."
      refute_nil @prefix, "You do not have an bigquery prefix to name the datasets and tables with."
      refute_nil @storage, "You do not have an active storage to run the tests."
      refute_nil @bucket, "You do not have a storage bucket to run the tests."

      super
    end

    def random_file_destination_name
      "kitten-test-data-#{SecureRandom.hex}.json"
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :bigquery is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :bigquery
    end

    def self.run_one_method klass, method_name, reporter
      result = nil
      reporter.prerecord klass, method_name
      (1..3).each do |try|
        result = Minitest.run_one_method(klass, method_name)
        break if (result.passed? || result.skipped?)
        puts "Retrying #{klass}##{method_name} (#{try})"
      end
      reporter.record result
    end
  end
end

def clean_up_bigquery_datasets
  puts "Cleaning up bigquery datasets after tests."
  $bigquery.datasets.all do |dataset|
    if dataset.dataset_id.start_with? $prefix
      dataset.tables.all(&:delete)
      dataset.delete
    end
  end
rescue => e
  puts "Error while cleaning up bigquery datasets after tests.\n\n#{e}"
end

def clean_up_storage_bucket
  puts "Cleaning up bigquery bucket after tests."
  $bucket.files.all &:delete
  safe_gcs_execute { $bucket.delete }
rescue => e
  puts "Error while cleaning up bigquery bucket after tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_bigquery_datasets
  clean_up_storage_bucket
end
