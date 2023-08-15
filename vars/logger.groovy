void info(String str) {
    logger('INFO', "[INFO] ${str}")
}

void warn(String str) {
    logger('WARNING', "[WARNING] ${str}")
}

void err(String str) {
    logger('ERROR', "[ERROR] ${str}")
}

void success(String str) {
    logger('SUCCESS', "[SUCCESS] ${str}")
}

void debug(String str) {
    logger('DEBUG', "[DEBUG] ${str}")
}

void bannerLogo(String content) {
    logger('INFO', content)
}

void bannerStage(String label) {
    def width = label.size() + 40
    banner(label.toUpperCase(), width, "*")
}

private void banner(String label = "stage", int width = 80, String pattern = "=") {
    def topBottomLine = pattern * width + "\n"
    def intermediateLine = pattern + ' ' * (width - 2) + pattern + "\n"
    def spacesForLabel = ((width - label.size()) / 2).intValue()
    def labelLine = (pattern + ' ' * spacesForLabel + label).padRight(width - 1) + pattern + "\n"

    def boxContent = topBottomLine +
        intermediateLine +
        labelLine +
        intermediateLine +
        topBottomLine

    logger('INFO', boxContent)
}

// Logger function to log messages with color
private void logger(level, message) {

    // Colors for different log levels
    def COLORS = [
        ERROR: "\u001B[31m",   // Red
        WARNING: "\u001B[33m", // Yellow
        INFO: "\u001B[34m",    // Green
        SUCCESS: "\u001B[32m", // Cyan
        DEBUG: "\u001B[36m",   // Blue
    ]

    // Log levels
    def LOG_LEVELS = ['ERROR', 'WARNING', 'INFO', 'SUCCESS', 'DEBUG']

    // Global log level
    def LOG_LEVEL = 'DEBUG'

    // Global log colorization enabled flag
    def colored_xterm = false
    try {
        ansiColor('xterm') {
            colored_xterm = true
        }
    } catch(Throwable ex) { }

    if (LOG_LEVELS.indexOf(level) <= LOG_LEVELS.indexOf(LOG_LEVEL)) {
        def color = COLORS[level]
        def resetColor = "\u001B[0m"
        def logMessage = colored_xterm ? "${color}${message}${resetColor}" : "${message}"
        println logMessage
    }
}

// Usage example
//info("This is an informational message.")
//warn("This is a warning message.")
//err("This is an error message.")
//success("This is a success message.")
//debug("This is a debug message.")
//bannerLogo("Banner Logo")
//bannerStage("My Stage")
