/**
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

import Kitura
import KituraContracts
import KituraCORS

import TodoBackendDataLayer

public struct RouterCreator {
    private let dataLayer: DataLayer
    private let dataLayerTodoConverter: DataLayerTodoConverter
    private let dataLayerErrorConverter = DataLayerErrorConverter()

    public init(dataLayer: DataLayer, baseURL: URL) {
        self.dataLayer = dataLayer
        self.dataLayerTodoConverter = DataLayerTodoConverter(baseURL: baseURL)
    }

    public func create(dataLayer: DataLayer, baseURL: URL) -> Router {
        let router = Router()

        let corsOptions = Options(allowedOrigin: .origin("https://www.todobackend.com"),
               methods: ["GET","POST", "PATCH", "DELETE", "OPTIONS"])
        router.all("/", middleware: CORS(options: corsOptions))

        router.get("/", handler: getTodos)

        return router
    }

    private func getTodos(completion: ([Todo]?, RequestError?) -> Void) {
       dataLayer.get() { result in
           switch result {
               case .success(let todos):
                   completion(todos.map { dataLayerTodoConverter.convert($0) }, nil)
               case .failure(let error):
                   completion(nil, dataLayerErrorConverter.convert(error))
           }
       }
    }
}
