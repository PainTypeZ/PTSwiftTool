//
//  PTSwiftTool.swift
//  PTPackage
//
//  Created by PainTypeZ on 2020/11/16.
//

import Foundation

public protocol StoryBoardName {
    var fileName: String { get set }
}

public struct PTSwiftTool {
    public let domain = FileManager.SearchPathDirectory.cachesDirectory
    public let mask = FileManager.SearchPathDomainMask.userDomainMask
    public var cachePath: String {
        guard let path = NSSearchPathForDirectoriesInDomains(domain, mask, true).first else {
            print("cachePath获取失败")
            return ""
        }
        return path
    }
    public var fileArray: [String] {
        guard let array = FileManager.default.subpaths(atPath: cachePath) else {
            print("fileArrary获取失败")
            return []
        }
        return array
    }
    /// 单例
    public static var shared = Self()
    private init() {

    }
    
    /// 获取故事板VC
    /// - Parameter stroyBoard: 遵守StoryBoardName协议的对象
    /// - Returns: 控制器类型
    public func creatViewControllerFrom<T: UIViewController>(_ storyboard: StoryBoardName) -> T? {
        let storyboard = UIStoryboard(name: storyboard.fileName, bundle: .main)
        return storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as? T
    }
    /// 退出App
    public func exitApp() {
        guard let window = UIApplication.shared.delegate?.window else {
            exit(0)
        }
        
        UIView.animate(withDuration: 1) {
            window?.alpha = 0
            window?.frame = CGRect(x: UIScreen.main.bounds.width / 2,
                                   y: UIScreen.main.bounds.height / 2,
                                   width: 0,
                                   height: 0)
        } completion: { _ in
            exit(0)
        }
    }
    /// 获取app缓存大小
    public func getCacheSize() -> String {
        var size: Double = 0
        fileArray.forEach {
            let path = (cachePath as NSString).appending("/\($0)")
            guard let floder = try? FileManager.default.attributesOfItem(atPath: path) else {
                print("floder获取失败")
                return
            }
            floder.forEach {
                guard $0.key == FileAttributeKey.size else {
                    return
                }
                size += ($0.value as AnyObject).doubleValue
            }
        }
        let cache = size / 1024 / 1024
        return String(cache) + "MB"
    }
    /// 清除app缓存
    public func clearAllCache() {
        fileArray.forEach {
            let path = (cachePath as NSString).appending("/\($0)")
            guard FileManager.default.fileExists(atPath: path) else {
                return
            }
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch let error {
                print("FileManagerError: " + error.localizedDescription)
            }
        }
    }
    /// 根据window获取顶层控制器
    public func getCurrentViewController() -> (UIViewController?) {
        var window = UIApplication.shared.keyWindow
        // 是否为当前显示的window
        if window?.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for windowTemp in windows where windowTemp.windowLevel == .normal {
                window = windowTemp
            }
        }
        let rootVC = window?.rootViewController
        return getCurrentViewController(currentViewController: rootVC)
    }
    /// 根据控制器获取顶层控制器
    public func getCurrentViewController(currentViewController: UIViewController?) -> UIViewController? {
        if currentViewController == nil {
            print("PTSwiftTool： 找不到顶层控制器")
            return nil
        }
        if let presentVC = currentViewController?.presentedViewController {
            // modal出来的 控制器
            return getCurrentViewController(currentViewController: presentVC)
        } else if let tabVC = currentViewController as? UITabBarController {
            // tabBar 的跟控制器
            if let selectVC = tabVC.selectedViewController {
                return getCurrentViewController(currentViewController: selectVC)
            }
            return nil
        } else if let naiVC = currentViewController as? UINavigationController {
            // 控制器是 nav
            return getCurrentViewController(currentViewController: naiVC.visibleViewController)
        } else {
            // 返回顶控制器
            return currentViewController
        }
    }
    /// 拨打电话
    public func call(phoneNumber: String) -> Bool {
        let phoneURL = "tel://" + phoneNumber
        guard let url = URL(string: phoneURL) else {
            return false
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
}
