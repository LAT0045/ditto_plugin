import Flutter
import UIKit
import DittoSwift

public class DittoPlugin: NSObject, FlutterPlugin {
    private var ditto: Ditto?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ditto_plugin", binaryMessenger: registrar.messenger())
        let instance = DittoPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "initializeDitto":
            initializeDitto(call: call, result: result)
        case "save":
            save(call: call, result: result)
        case "delete":
            delete(call: call, result: result)
        case "getAllTasks":
            getAllTasks(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initializeDitto(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let arguments = call.arguments as? [String: String],
            let appId = arguments["appId"], 
            let token = arguments["token"] else {
          result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "Invalid appId or token provided", 
                              details: nil))
          return
      }

      print("Received appId: \(appId), token: \(token)") 

      self.ditto = Ditto(
          identity: .onlinePlayground(appID: appId, token: token)
      )

      result(nil) 
  }


    private func save(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let ditto = self.ditto else {
          result(FlutterError(code: "DITTO_NOT_INITIALIZED",
                              message: "Ditto is not initialized", details: nil))
          return
      }

      guard let arguments = call.arguments as? [String: Any],
            let body = arguments["body"] as? String,
            let isCompleted = arguments["isCompleted"] as? Bool,
            let documentId = arguments["_id"] as? String?  else { 
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
          return
      }

      do {
          var task: [String: Any] = [
              "body": body,
              "isCompleted": isCompleted,
              "isDeleted": false,
              "invitationIds": [:] 
          ]

          if let docId = documentId {
              task["_id"] = docId 
          }

          try ditto.store["tasks"].upsert(task)
          result(nil) 
      } catch {
          result(FlutterError(code: "DITTO_ERROR", message: "Error saving task", details: error.localizedDescription))
      }
    }
    private func delete(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
    }

    private func getAllTasks(call: FlutterMethodCall, result: @escaping FlutterResult) {
      
    }
}