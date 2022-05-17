//
//  String+Path.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/18.
//

import Foundation

public func DocumemtPath() -> String {
    let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    return documentDir
}

func SDKPath() -> String {
    return DocumemtPath().appending("/CloudroomVideoSDK")
}
