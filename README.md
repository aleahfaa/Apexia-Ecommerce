# Apexia E-Commerce Project

Source code to refacrored Apexia E-Commerce Project with clean architecture, comprehensive error handling, and professional user experience. The project is refactored and polished by [Iffa Amalia Sabrina](https://github.com/aleahfaa).

---

## Problems
1. **All logic** (UI, API calls, state management, and business logic) **is mixed in a single file**. There is no separation between presentation layer, data layer, and business logic which makes the code is very difficult to maintain. Mixing all logic together can lead to high code coupling, small changes can break other functionality, and difficult to onboard new developers.
2. There is **no error handling**, so if the network error, response format is incorrect, or server returns an error status code the application will crash. The user also won't received any feedback on what went wrong, so they can only guess.
3. The **state management is poor**. Excessive use of `setState()` without clear structure, state is not managed properly, race conditions can occur, and no separation between UI and data state can cause the UI and data out of sync, UI displays incorrect data if the API fails, and users are confused because they do not know whether the action was successful or not.
4. If the API return null or using different format and if there is a missing fields will cause a crash because there is **no data validation**.
5. There is **no mechanism to handle multiple simultaneous requests**, **no rollback mechanism** if the API call is failed, and user can spam button clicks and trigger multiple API calls. Those kind of thing can cause data inconsistency, duplicate requests to server, and cart state can corrupt.
6. **Memory leaks and resource management** cause potential memory leaks, `setState()` called after dispose error, HTTP requests cannot be cancelled when the widget disposed, and hung request which can cause app freeze.
7. There are several **issues related to user experiences**, such as no proper loading state, no user-friendly error messages, no confirmation dialog for destructive actions, no feedback when the action is being processed, and minimum empty state handling. Those issues can cause poor user experience.
8. The **hardcoded values** and magic number are difficult to test, cannot be configured per environment, and the code is not reusable.
9. There is **no error builder for the image loading**, **no handling for edge cases**, **no null safety**, **no tooltip or accessibility labels**.
10. In the code, there is **no proper type annotations**, **mixed paradigm**, **no code reusability**, **inconsistent naming conventions**, and **no documentation**.

## Solution
1. Implemented clean architecture to separate each logic, make it easier to test each layer independently, better code architecture, and scalable architecture.
2. Comprehensive error handling is implemented to give a user-friendly error messages, granular error handling, and better debugging.
3. I use Provider state management in the code to centralized the state management, optimistic updates with rollback, reactive UI updates, make it easier to test, and no race condition.
4. I implement type-safe data models for type safety, null safety, set a default values for missing data, computed properties, and easy serialization or deserialization.
5. I improved the user experience with loading states to give a clear feedback to the user, give a proper loading indicators, add error recovery options, and add empty state handling.
6. To prevent accidential deletions and adjust the user experience, I add confirmation dialogs for destructive actions.
7. The `CartItemWidget` extracted as the reusable components to make the it easier to maintain and consistent UI. The widget can also be use in other screens which will reduce the developer work.
8. Implement dependency injection to make it testable, configurable, loose coupling, and this implementation is also needed for different environments.
9. Network request management is implemented to prevent hung requests and improve the performance and user experience.
10. The accessibility is improved to graceful image loading failures, add loading indicators for image, add tooltips for accessibility, and make the user experience better.

## Reasoning
- The reason why I choose to use Provider as the state management in this project is because of the simplicity and for this case Provider is already powerful enough. Provider also easy to migrate to Riverpod, if it is needed.
- I am creating a custom exception class (`ApiException` class) because it can catches specific exception types, can includes status code and details, can handle different errors differently, and easier to logging and monitoring.
- Separate API service layer make us as a developer able to mock API service for testing, use the API service in multiple providers or pages, only file that responsible of API service handles API calls, easier to change HTTP client or add inceptors, and easier to switch or change API endpoints.
- The widget extraction make the widget rebuilds more efficient, can be use in other screens, easier to test individual components, changes isolated to specific widgets, and the make the code structure easier to understand because it is cleaner.
- The reason why I am using `enum` for status is because it cannot use invalid status, easy to add new states, and work well with switch statements.

## Improvement Implementation
1. Optimize state with Provider state management
2. Add 10s timeout and proper handling for API calls
3. Add network caching and loading indicators for image loading
4. Proper widget disposal (no memory leaks)
5. Comprehensive error handling
6. Full data validation with defaults
7. Optimistic updates with rollback mechanism
8. Type safety and null safety throughout
9. Clear loading states at all times
10. User-friendly error messages with retry options
11. Confirmation dialogs for destructive actions
12. Loading indicators for images
13. Empty state with helpful guidance
14. Snackbar notifications for feedback
15. Enhanced the developer experience by implementing clean architecture, self-documenting code (clear naming and structure), add reusable components, make the code testable, and consistent patterns throughout codebase

## Future Enhancement
1. Add pagination for large cart lists
2. Implement search or filter functionality
3. Add product details page
4. Integrate wish list feature
5. Add order history
6. Implement push notifications
7. Add analytics tracking
8. Implement caching layer
9. Add offline support
10. Multi-language support
