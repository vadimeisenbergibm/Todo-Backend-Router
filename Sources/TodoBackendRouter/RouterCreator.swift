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
        let dataLayerConverter = DataLayerConverter(baseURL: baseURL)

        let router = Router()
        cors(router: router)
        getTodo(router: router, dataLayer: dataLayer, dataLayerConverter: dataLayerConverter)
        getTodos(router: router, dataLayer: dataLayer, dataLayerConverter: dataLayerConverter)

        addTodo(router: router, dataLayer: dataLayer, dataLayerConverter: dataLayerConverter)

        deleteTodo(router: router, dataLayer: dataLayer, dataLayerConverter: dataLayerConverter)
        deleteTodos(router: router, dataLayer: dataLayer, dataLayerConverter: dataLayerConverter)

        return router
    }

    private static func cors(router: Router) {
        let corsOptions = Options(allowedOrigin: .origin("https://www.todobackend.com"),
                                  methods: ["GET","POST", "PATCH", "DELETE", "OPTIONS"])
        router.all("/", middleware: CORS(options: corsOptions))
    }

    private static func getTodo(router: Router, dataLayer: DataLayer,
                                dataLayerConverter: DataLayerConverter) {
        router.get("/") { (id: String, completion: ((Todo?, RequestError?) -> Void)) in
            dataLayer.get(id: id) { result in
                switch result {
                case .success(let todo):
                    completion(dataLayerConverter.convert(todo), nil)
                case .failure(let error):
                    completion(nil, dataLayerConverter.convert(error))
                }
            }
        }
    }

    private static func getTodos(router: Router, dataLayer: DataLayer,
                                 dataLayerConverter: DataLayerConverter) {
        router.get("/") { (completion: (([Todo]?, RequestError?) -> Void)) in
            dataLayer.get() { result in
                switch result {
                case .success(let todos):
                    completion(todos.map { dataLayerConverter.convert($0) }, nil)
                case .failure(let error):
                    completion(nil, dataLayerConverter.convert(error))
                }
            }
        }
    }


    private static func addTodo(router: Router, dataLayer: DataLayer,
                                dataLayerConverter: DataLayerConverter) {
        var dataLayer = dataLayer
        router.post("/") { (todoPatch: TodoPatch, completion: (Todo?, RequestError?) -> Void) in
            guard let title = todoPatch.title, title != "" else {
                return completion(nil, .badRequest)
            }
            let completed = todoPatch.completed ?? false
            let order = todoPatch.order

            dataLayer.add(title: title, order: order, completed: completed) { result in
                switch result {
                case .success(let todo):
                    completion(dataLayerConverter.convert(todo), nil)
                case .failure(let error):
                    completion(nil, dataLayerConverter.convert(error))
                }
            }
        }
    }

    private static func deleteTodo(router: Router, dataLayer: DataLayer,
                                   dataLayerConverter: DataLayerConverter) {
        var dataLayer = dataLayer
        router.delete("/") { (id: String, completion: (RequestError?) -> Void) in
            dataLayer.delete(id: id) { result in
                switch result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(dataLayerConverter.convert(error))
                }
            }
        }
    }

    private static func deleteTodos(router: Router, dataLayer: DataLayer,
                                    dataLayerConverter: DataLayerConverter) {
        var dataLayer = dataLayer
        router.delete("/") { (completion: (RequestError?) -> Void) in
            dataLayer.delete() { result in
                switch result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(dataLayerConverter.convert(error))
                }
            }
        }
    }
}
