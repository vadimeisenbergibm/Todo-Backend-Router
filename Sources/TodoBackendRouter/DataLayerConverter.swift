/*
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
 */

import Foundation
import TodoBackendDataLayer
import KituraContracts

struct DataLayerConverter {
    let baseURL: URL

    func convert(_ todo: TodoBackendDataLayer.Todo) -> Todo {
        let url = baseURL.appendingPathComponent(todo.id)
        return Todo(title: todo.title, order: todo.order, completed: todo.completed, url: url)
    }

    func convert(_ error: DataLayerError) -> RequestError {
        switch error {
        case .todoNotFound: return .notFound
        case .internalError: return .internalServerError
        }
    }
}
