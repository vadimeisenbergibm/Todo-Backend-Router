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
    private let dataLayerConverter: DataLayerConverter

    public init(dataLayer: DataLayer, baseURL: URL) {
        self.dataLayer = dataLayer
        self.dataLayerConverter = DataLayerConverter(baseURL: baseURL)
    }

    public func create() -> Router {
        let router = Router()

        let corsOptions = Options(allowedOrigin: .origin("https://www.todobackend.com"),
               methods: ["GET","POST", "PATCH", "DELETE", "OPTIONS"])
        router.all("/", middleware: CORS(options: corsOptions))

        router.get("/", handler: getTodos)
        router.get("/", handler: getTodo)

        router.post("/", handler: addTodo)

        router.delete("/", handler: deleteTodos)
        router.delete("/", handler: deleteTodo)

        router.patch("/", handler: updateTodo)

        return router
    }

    private func getTodos(completion: ([Todo]?, RequestError?) -> Void) {
        dataLayer.get() { result in
            completionWithMultipleTodos(result: result, completion: completion)
        }
    }


    private func getTodo(id: String, completion: (Todo?, RequestError?) -> Void) {
        dataLayer.get(id: id) { result in
            completionWithSingleTodo(result: result, completion: completion)
        }
    }

    private func addTodo(todoPatch: TodoPatch, completion: (Todo?, RequestError?) -> Void ) {
        guard let title = todoPatch.title, title != "" else {
            return completion(nil, .badRequest)
        }
        let completed = todoPatch.completed ?? false
        let order = todoPatch.order

        dataLayer.add(title: title, order: order, completed: completed) { result in
            completionWithSingleTodo(result: result, completion: completion)
        }
    }

    private func deleteTodo(id: String, completion: (RequestError?) -> Void) {
        dataLayer.delete(id: id) { result in
            completionWithoutTodos(result: result, completion: completion)
        }
    }

    private func deleteTodos(completion: (RequestError?) -> Void) {
        dataLayer.delete() { result in
             completionWithoutTodos(result: result, completion: completion)
        }
    }

    private func updateTodo(id: String, todoPatch: TodoPatch,
                            completion: (Todo?, RequestError?) -> Void ) {
        dataLayer.update(id: id, title: todoPatch.title, order: todoPatch.order,
                         completed: todoPatch.completed) { result in
            completionWithSingleTodo(result: result, completion: completion)
        }
    }

    private func completionWithMultipleTodos(result: Result<[TodoBackendDataLayer.Todo]>,
                                             completion: ([Todo]?, RequestError?) -> Void) {
        switch result {
        case .success(let todos):
            completion(todos.map { dataLayerConverter.convert($0) }, nil)
        case .failure(let error):
            completion(nil, dataLayerConverter.convert(error))
        }
    }

    private func completionWithSingleTodo(result: Result<TodoBackendDataLayer.Todo>,
                                             completion: (Todo?, RequestError?) -> Void) {
        switch result {
        case .success(let todo):
            completion(dataLayerConverter.convert(todo), nil)
        case .failure(let error):
            completion(nil, dataLayerConverter.convert(error))
        }
    }

    private func completionWithoutTodos(result: Result<Void>,
                                        completion: (RequestError?) -> Void) {
        switch result {
        case .success:
            completion(nil)
        case .failure(let error):
            completion(dataLayerConverter.convert(error))
        }
    }
}
