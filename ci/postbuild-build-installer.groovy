def matcher = manager.getLogMatcher("^.*mingwGitDevEnv-([0-9a-z\\.-]+)\\.exe\$")
if (matcher?.matches()) {
    manager.addShortText(matcher.group(1), "grey", "white", "0px", "white")
}
