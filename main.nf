nextflow.enable.dsl=2

params.path = params.path ?: workflow.launchDir

def visibleChildren(File directory) {
    (directory.listFiles() ?: [] as File[])
        .findAll { !it.name.startsWith('.') }
        .sort { a, b -> a.name <=> b.name }
}

def printTree(File node, String prefix, boolean isLast) {
    def connector = isLast ? '└── ' : '├── '
    println "${prefix}${connector}${node.name}"

    if (node.isDirectory()) {
        def children = visibleChildren(node)
        def childPrefix = prefix + (isLast ? '    ' : '│   ')
        children.eachWithIndex { child, index ->
            printTree(child, childPrefix, index == children.size() - 1)
        }
    }
}

workflow {
    File root = file(params.path as String).toFile().canonicalFile

    if (!root.exists()) {
        error "Path does not exist: ${root}"
    }

    println '.'
    def children = visibleChildren(root)
    children.eachWithIndex { child, index ->
        printTree(child, '', index == children.size() - 1)
    }
}
