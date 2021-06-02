import Dispatch
import Foundation
import Swifter

let server = HttpServer()
let application = WebApplication(server)

do {
    try server.start(8080, forceIPv4: true)
    print("MedicalRegistry has started on port = \(try server.port()), workDir = \(FileManager.default.currentDirectoryPath)")
    dispatchMain()
} catch {
    print("MedicalRegistry start error: \(error)")
}


