import IMGLYEditor
import SwiftUI

struct NotificationsAndDialogsSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  @State private var isPresented = false
  @State private var isSavedAlertPresented = false

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              // highlight-notificationsAndDialogs-errorAlert
              Dock.Button(id: "notifications.errorAlert") { context in
                let error = NSError(
                  domain: "MyApp",
                  code: 1,
                  userInfo: [NSLocalizedDescriptionKey: "Could not save your design."],
                )
                context.eventHandler.send(.showErrorAlert(error))
              } label: { _ in
                Label("Error", systemImage: "exclamationmark.triangle")
              }
              // highlight-notificationsAndDialogs-errorAlert

              // highlight-notificationsAndDialogs-closeConfirm
              Dock.Button(id: "notifications.closeConfirm") { context in
                context.eventHandler.send(.showCloseConfirmationAlert)
              } label: { _ in
                Label("Confirm", systemImage: "questionmark.circle")
              }
              // highlight-notificationsAndDialogs-closeConfirm

              // highlight-notificationsAndDialogs-customSheet
              Dock.Button(id: "notifications.customSheet") { context in
                context.eventHandler.send(.openSheet(
                  style: .default(isFloating: true, detent: .medium, detents: [.medium, .large]),
                  content: {
                    VStack(spacing: 16) {
                      Text("Custom Dialog")
                        .font(.headline)
                      Text("Present any SwiftUI view as a modal sheet.")
                        .multilineTextAlignment(.center)
                      Button("Done") {
                        context.eventHandler.send(.closeSheet)
                      }
                      .buttonStyle(.borderedProminent)
                    }
                    .padding()
                  },
                ))
              } label: { _ in
                Label("Sheet", systemImage: "rectangle.stack")
              }
              // highlight-notificationsAndDialogs-customSheet

              // highlight-notificationsAndDialogs-progress
              Dock.Button(id: "notifications.progress") { context in
                context.eventHandler.send(.exportProgress(.relative(0.35)))
              } label: { _ in
                Label("Progress", systemImage: "arrow.triangle.2.circlepath")
              }
              // highlight-notificationsAndDialogs-progress

              // highlight-notificationsAndDialogs-completed
              Dock.Button(id: "notifications.completed") { context in
                context.eventHandler.send(.exportCompleted {
                  print("Export sheet dismissed")
                })
              } label: { _ in
                Label("Completed", systemImage: "checkmark.circle")
              }
              // highlight-notificationsAndDialogs-completed

              // highlight-notificationsAndDialogs-nativeButton
              Dock.Button(id: "notifications.nativeAlert") { _ in
                isSavedAlertPresented = true
              } label: { _ in
                Label("Native", systemImage: "bell")
              }
              // highlight-notificationsAndDialogs-nativeButton
            }
          }
        }
      }
  }

  var body: some View {
    Button("Use the Editor") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      // highlight-notificationsAndDialogs-nativeAlert
      ModalEditor {
        editor
      }
      .alert("Saved", isPresented: $isSavedAlertPresented) {
        Button("OK", role: .cancel) {}
      } message: {
        Text("Your design has been saved.")
      }
      // highlight-notificationsAndDialogs-nativeAlert
    }
  }
}

#Preview {
  NotificationsAndDialogsSolution()
}
