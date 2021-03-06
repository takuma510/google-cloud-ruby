# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: google/cloud/dialogflow/v2/session_entity_type.proto for package 'google.cloud.dialogflow.v2'
# Original file comments:
# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'grpc'
require 'google/cloud/dialogflow/v2/session_entity_type_pb'

module Google
  module Cloud
    module Dialogflow
      module V2
        module SessionEntityTypes
          # Entities are extracted from user input and represent parameters that are
          # meaningful to your application. For example, a date range, a proper name
          # such as a geographic location or landmark, and so on. Entities represent
          # actionable data for your application.
          #
          # Session entity types are referred to as **User** entity types and are
          # entities that are built for an individual user such as
          # favorites, preferences, playlists, and so on. You can redefine a session
          # entity type at the session level.
          #
          # For more information about entity types, see the
          # [Dialogflow documentation](https://dialogflow.com/docs/entities).
          class Service

            include GRPC::GenericService

            self.marshal_class_method = :encode
            self.unmarshal_class_method = :decode
            self.service_name = 'google.cloud.dialogflow.v2.SessionEntityTypes'

            # Returns the list of all session entity types in the specified session.
            rpc :ListSessionEntityTypes, ListSessionEntityTypesRequest, ListSessionEntityTypesResponse
            # Retrieves the specified session entity type.
            rpc :GetSessionEntityType, GetSessionEntityTypeRequest, SessionEntityType
            # Creates a session entity type.
            rpc :CreateSessionEntityType, CreateSessionEntityTypeRequest, SessionEntityType
            # Updates the specified session entity type.
            rpc :UpdateSessionEntityType, UpdateSessionEntityTypeRequest, SessionEntityType
            # Deletes the specified session entity type.
            rpc :DeleteSessionEntityType, DeleteSessionEntityTypeRequest, Google::Protobuf::Empty
          end

          Stub = Service.rpc_stub_class
        end
      end
    end
  end
end
