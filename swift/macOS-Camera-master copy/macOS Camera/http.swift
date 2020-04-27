//
//  http.swift
//  macOS Camera
//
//  Created by Andriy Levitskyy on 24.04.2020.
//  Copyright © 2020 Keyboarder Co. All rights reserved.
//

import Foundation
import Alamofire

func saySomething(text: String) {
    print(text)
}


func sendData(count: Int, data: String){
    let file: [String: String] = [
        "file" : data,
        "name":  "av",
        "count": String(count)
    ]
    AF.request("http://95.217.33.216:8000/test",
               method: .post,
               parameters: file
    ).responseString {response in
        let statusCode = (response.response?.statusCode)!
        print(statusCode)
    }}
