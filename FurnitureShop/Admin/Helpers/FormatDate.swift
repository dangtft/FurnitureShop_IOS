//
//  FormatDate.swift
//  Admin_DasboardUI
//
//  Created by haidangnguyen on 20/12/24.
//

import Foundation

// Định dạng ngày tháng
public func formattedDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    return dateFormatter.string(from: date)
}
