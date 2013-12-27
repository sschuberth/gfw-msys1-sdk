/*
 * Parse prove's Test Summary Report
 */

def patternSummary = ~/^.*\(.*Failed\: (\d+)\).*$/
def patternDetails = ~/^.*Failed test.*\:.*$/
def map = [:]
def prevLine = "Test Summary Report"
def failedCount = 0

manager.build.logFile.eachLine { line ->
    matcher = patternDetails.matcher(line)
    if (matcher?.matches()) {
        map[prevLine] = line
        matcher = patternSummary.matcher(prevLine)
        if (matcher?.matches()) {
            failedCount += matcher.group(1).toInteger()
        }
    }
    prevLine = line
}

if (map.size() > 0) {
    summary = manager.createSummary("error.gif")
    summary.appendText("The following test(s) failed:<ul>", false)
    map.sort().each {
        summary.appendText("<li><b>$it.key:</b>$it.value</li>", false)
    }
    summary.appendText("</ul>", false)
    manager.addShortText(failedCount + " test(s) failed", "grey", "white", "0px", "white")
}
