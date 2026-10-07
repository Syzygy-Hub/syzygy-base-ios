import XCTest
@testable import SyzygyBase

@MainActor
final class DIGraphTests: XCTestCase {

    func testMakeLoginViewModelSucceeds() {
        // Uses legacy shims — compiles and runs without SPM packages linked
        let vm = AppDependencies.makeLoginViewModel()
        XCTAssertNotNil(vm)
    }

    func testContainerIsCreated() {
        // Container is created lazily; access it to trigger creation.
        // Full resolution tests become meaningful once SPM packages are linked.
        _ = AppDependencies.container
        // reaching here without crash = pass
    }
}
