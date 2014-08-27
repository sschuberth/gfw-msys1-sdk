def workspace = manager.build.workspace.getRemote()

if (manager.contains(new File(workspace + File.separator + "mingw-get.log"), "^.*\\*\\*\\* ERROR \\*\\*\\*.*\$")) {
    def message = "mingw-get reported an error!"
    manager.createSummary("error.gif").appendText("<b>" + message + "</b>", false)
    manager.addErrorBadge(message)
    manager.buildUnstable()
}
