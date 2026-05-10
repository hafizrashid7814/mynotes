// Login Exceptions

class userNotFoundAuthException implements Exception {}

class wrongPasswordAuthException implements Exception {}

// Registration Exceptions

class weakPasswordAuthException implements Exception {}
class emailAlreadyInUseAuthException implements Exception {}

class invalidEmailAuthException implements Exception {}

// Generic Exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

