import Foundation
import XCTest

public enum Utils {
    public static func generateResource(resource: String) {
        guard let resourceUrl = Bundle.module.url(forResource: resource, withExtension: "json") else {
            XCTFail("Error can't find the json file")
            return
        }
        do {
            let data = try Data(contentsOf: resourceUrl, options: .mappedIfSafe)
            MockedTasksExecutor.data = data
        } catch {
            XCTFail("Error can't get data from json")
        }
    }
}
