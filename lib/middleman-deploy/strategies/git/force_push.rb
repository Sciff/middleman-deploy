module Middleman
  module Deploy
    module Strategies
      module Git
        class ForcePush < Base

          def process
            Dir.chdir(self.build_dir) do
              add_remote_url
              checkout_branch
              commit_branch('-f')
            end
            if self.user && self.host && self.path
              port = self.port ? self.port : 22
              key = self.ssh_forward ? '-A' : ''
              ssh = "ssh #{key} #{self.user}@#{self.host} -p #{port}"
              folder = `#{ssh} "if [ -d #{self.path} ]; then echo "yes"; fi;"`
              folder = `#{ssh} "ls -v #{self.path}"` unless folder.empty?
              if folder.empty?
                url = get_remote_url
                `#{ssh} "git clone #{url} -b #{self.branch} #{self.path}"`
              else
                `#{ssh} "cd #{self.path} && git pull"`
              end
            end
          end

        private

          def add_remote_url
            url = get_remote_url

            unless File.exists?('.git')
              `git init`
              `git remote add origin #{url}`
            else
              # check if the remote repo has changed
              unless url == `git config --get remote.origin.url`.chop
                `git remote rm origin`
                `git remote add origin #{url}`
              end
            end
          end

          def get_remote_url
            remote  = self.remote
            url     = remote

            # check if remote is not a git url
            unless remote =~ /\.git$/
              url = `git config --get remote.#{url}.url`.chop
            end

            # if the remote name doesn't exist in the main repo
            if url == ''
              puts "Can't deploy! Please add a remote with the name '#{remote}' to your repo."
              exit
            end

            url
          end

        end
      end
    end
  end
end
