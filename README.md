#### 准备工作
首先，我们分别用 Xcode 与 Android Studio 快速建立一个只有首页的基本工程，工程名分别为 iOSDemo 与 AndroidDemo.

这时，Android 工程就已经准备好了；而对于 iOS 工程来说，由于基本工程并不支持以组件化的方式管理项目，因此我们还需要多做一步，将其改造成使用 CocoaPods 管理的工程，也就是要在 iOSDemo 根目录下创建一个只有基本信息的 Podfile 文件：

```
target 'iOSDemo' do
  use_frameworks!

  target 'iOSDemoTests' do
    inherit! :search_paths
  end

  target 'iOSDemoUITests' do
  end
end
```
然后，在命令行输入 pod install 后，会自动生成一个 iOSDemo.xcworkspace 文件，这时我们就完成了 iOS 工程改造。


</br>
#### 集成 React-Native

原生工程对 React-Native 的依赖主要分为两部分：
+ 对react natvie核心库的依赖
+ React代码和资源的bundle依赖

创建同级目录的React-Native项目, 上面创建的的iOSDemo，AndroidDemo 就对这个React-Native的核心库和bundle进行依赖。

```
react-native init react_demo
```

</br>
然后我们分别对 react_demo 进行集成
### iOS 模块集成

在 iOS 平台，原生工程对 React-Native 的依赖分别是:

+ 对react natvie核心库的依赖；
+ React代码和资源的bundle依赖(release模式使用离线包)

</br>
我们打开React-Native项目ios目录下的Podfile，把需要依赖的Pods拷贝到iOSDemo下的Podfile，对相对路径进行修改


```
workspace 'IOSDemo.xcworkspace'

def import_react_native
  
  require_relative '../react_demo/node_modules/@react-native-community/cli-platform-ios/native_modules'
  react_native = "../react_demo/node_modules/react-native"
  
  pod 'FBLazyVector', :path => "#{react_native}/Libraries/FBLazyVector"
  pod 'FBReactNativeSpec', :path => "#{react_native}/Libraries/FBReactNativeSpec"
  pod 'RCTRequired', :path => "#{react_native}/Libraries/RCTRequired"
  pod 'RCTTypeSafety', :path => "#{react_native}/Libraries/TypeSafety"
  pod 'React', :path => "#{react_native}/"
  pod 'React-Core', :path => "#{react_native}/"
  pod 'React-CoreModules', :path => "#{react_native}/React/CoreModules"
  pod 'React-Core/DevSupport', :path => "#{react_native}/"
  pod 'React-RCTActionSheet', :path => "#{react_native}/Libraries/ActionSheetIOS"
  pod 'React-RCTAnimation', :path => "#{react_native}/Libraries/NativeAnimation"
  pod 'React-RCTBlob', :path => "#{react_native}/Libraries/Blob"
  pod 'React-RCTImage', :path => "#{react_native}/Libraries/Image"
  pod 'React-RCTLinking', :path => "#{react_native}/Libraries/LinkingIOS"
  pod 'React-RCTNetwork', :path => "#{react_native}/Libraries/Network"
  pod 'React-RCTSettings', :path => "#{react_native}/Libraries/Settings"
  pod 'React-RCTText', :path => "#{react_native}/Libraries/Text"
  pod 'React-RCTVibration', :path => "#{react_native}/Libraries/Vibration"
  pod 'React-Core/RCTWebSocket', :path => "#{react_native}/"
  
  pod 'React-cxxreact', :path => "#{react_native}/ReactCommon/cxxreact"
  pod 'React-jsi', :path => "#{react_native}/ReactCommon/jsi"
  pod 'React-jsiexecutor', :path => "#{react_native}/ReactCommon/jsiexecutor"
  pod 'React-jsinspector', :path => "#{react_native}/ReactCommon/jsinspector"
  pod 'ReactCommon/jscallinvoker', :path => "#{react_native}/ReactCommon"
  pod 'ReactCommon/turbomodule/core', :path => "#{react_native}/ReactCommon"
  pod 'Yoga', :path => "#{react_native}/ReactCommon/yoga"
  
  pod 'DoubleConversion', :podspec => "#{react_native}/third-party-podspecs/DoubleConversion.podspec"
  pod 'glog', :podspec => "#{react_native}/third-party-podspecs/glog.podspec"
  pod 'Folly', :podspec => "#{react_native}/third-party-podspecs/Folly.podspec"

end

target 'IOSDemo' do
  use_frameworks!
  import_react_native
  
  target 'IOSDemoTests' do
    inherit! :search_paths
  end

  target 'IOSDemoUITests' do
  end

end


```

</br>
pod install 一下，React-Native 模块就集成进 iOS 原生工程中了。


接下来我们打开iOSDemo工程 在Build Phases加入脚本，添加启动Packager服务脚本
</br>

```
export RCT_METRO_PORT="${RCT_METRO_PORT:=8081}"
echo "export RCT_METRO_PORT=${RCT_METRO_PORT}" > "${SRCROOT}/../react_demo/node_modules/react-native/scripts/.packager.env"
if [ -z "${RCT_NO_LAUNCH_PACKAGER+xxx}" ] ; then
  if nc -w 5 -z localhost ${RCT_METRO_PORT} ; then
    if ! curl -s "http://localhost:${RCT_METRO_PORT}/status" | grep -q "packager-status:running" ; then
      echo "Port ${RCT_METRO_PORT} already in use, packager is either not running or not running correctly"
      exit 2
    fi
  else
    open "$SRCROOT/../react_demo/node_modules/react-native/scripts/launchPackager.command" || echo "Can't start packager automatically"
  fi
fi

```

</br>
我们在修改一下iOSDemo ViewController 在storyboard添加按钮与点击事件，点击按钮跳转react-native界面

```
  @IBAction func present(_ sender: UIButton) {
    var jsCodeLocation: URL!
    #if DEBUG
    jsCodeLocation = URL(string: "http://10.30.10.155:8081/index.bundle?platform=ios")!
    #else
    jsCodeLocation = Bundle.main.url(forResource: "bundle/index.ios", withExtension: "jsbundle")
    #endif
    let rootView = RCTRootView(bundleURL: jsCodeLocation!, moduleName: "react_demo", initialProperties: nil, launchOptions: nil)
    let vc = UIViewController()
    vc.view = rootView
    present(vc, animated: true, completion: nil)
  }
```

</br>

现在我们只是集成了对DEBUG模式下的支持，接下来我来集成release模式。release模式需要生成react-native 离线包bundle.

</br>
我们在react_demo根目录下执行生成离线包命令

```
react-native bundle --entry-file index.js --platform ios --dev false --bundle-output ./ios/bundle/index.ios.jsbundle --assets-dest ./ios/bundle
```

* --entry-file ,ios或者android入口的js名称，比如index.js
*  --platform ,平台名称(ios或者android)
*  --dev ,设置为false的时候将会对JavaScript代码进行优化处理。
*  --bundle-output, 生成的jsbundle文件的名称，比如./ios/bundle/index.ios.jsbundle（bundle目录如果没有手动创建一个，要不然找不到路径）
*  --assets-dest 图片以及其他资源存放的目录,比如./ios/bundle

最后我们再iOSDemo 右键点击 Add Files to "iOSDemo" 选择我们生成的离线包bundle, 不要勾选Copy items if needed 点击Add, 这样我们对release模式的离线包就添加进来了，对React代码和资源的bundle依赖就完成了。

点击xcode运行，最后运行程序，点击跳转，官方的 react-native component 也展示出来了。至此，iOS 工程的接入就完了。


![](/Users/app/Desktop/ios_demo_s.png)

</br>
</br>




