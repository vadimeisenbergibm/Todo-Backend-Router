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

import Kitura
import KituraCORS
import LoggerAPI

import TodoBackendDataLayer

public struct RouterCreator {
    public static func create(dataLayer: DataLayer) -> Router {
        let router = Router()

        router.all("/", middleware: CORS(options: Options(allowedOrigin: .origin("https://www.todobackend.com"),
                                                          methods: ["GET","POST", "PATCH", "DELETE", "OPTIONS"],
                                                          allowedHeaders: ["Content-Type"],
                                                          preflightContinue: true)))

        router.options("/") { _, response, next in
            response.status(.OK)
            next()
        }

        router.get("/") { _, response, next in
            response.status(.OK)
            next()
        }
        return router
    }
}
