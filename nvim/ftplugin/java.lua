local config = {
    cmd = {'jdtls'},
    root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvn', 'pom.xml'}, { upward = true })[1]),
    settings = {
        java = {
            imports = {
                gradle = {
                    wrapper = {
                        checksums = {
                            { sha256 = "81a82aaea5abcc8ff68b3dfcb58b3c3c429378efd98e7433460610fecd7ae45f", allowed = true }
                        }
                    }
                }
            }
        }
    }
}
require('jdtls').start_or_attach(config)
