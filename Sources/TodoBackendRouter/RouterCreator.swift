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

    public static func create(dataLayer: DataLayer, baseURL: URL) -> Router {
        var dataLayer = dataLayer
        let dataLayerTodoConverter = DataLayerTodoConverter(baseURL: baseURL)
        let dataLayerErrorConverter = DataLayerErrorConverter()

        func getTodos(completion: ([Todo]?, RequestError?) -> Void) {
            dataLayer.get() { result in
                switch result {
                case .success(let todos):
                    completion(todos.map { dataLayerTodoConverter.convert($0) }, nil)
                case .failure(let error):
                    completion(nil, dataLayerErrorConverter.convert(error))
                }
            }
        }

        func addTodo(todoPatch: TodoPatch, completion: (Todo?, RequestError?) -> Void ) {
            guard let title = todoPatch.title, title != "" else {
                return completion(nil, .badRequest)
            }
            let completed = todoPatch.completed ?? false
            let order = todoPatch.order

            dataLayer.add(title: title, order: order, completed: completed) { result in
                switch result {
                case .success(let todo):
                    completion(dataLayerTodoConverter.convert(todo), nil)
                case .failure(let error):
                    completion(nil, dataLayerErrorConverter.convert(error))
                }
            }
        }

        let router = Router()

        let corsOptions = Options(allowedOrigin: .origin("https://www.todobackend.com"),
               methods: ["GET","POST", "PATCH", "DELETE", "OPTIONS"])
        router.all("/", middleware: CORS(options: corsOptions))

        router.get("/", handler: getTodos)
        router.post("/", handler: addTodo)
        return router
    }
}
