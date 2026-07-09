import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private let channelRouter = ChannelRouter()

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    channelRouter.register(with: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }
}
