module Middleman
  module Deploy
    module Strategies
      module Git
        class Base
          attr_accessor :branch, :build_dir, :remote, :user, :host, :port, :path, :ssh_forward

          def initialize(build_dir, remote, branch, user = nil, host = nil, port = 22, path = nil, ssh_forward = nil)
            self.branch    = branch
            self.build_dir = build_dir
            self.remote    = remote
            self.user      = user
            self.host      = host
            self.port      = port
            self.path      = path
            self.ssh_forward   = ssh_forward
          end

          def process
            raise NotImplementedError
          end

        protected

          def add_signature_to_commit_message(base_message)
            signature = "#{Middleman::Deploy::PACKAGE} #{Middleman::Deploy::VERSION}"
            time      = "#{Time.now.utc}"

            "#{base_message} at #{time} by #{signature}"
          end

          def checkout_branch
            # if there is a branch with that name, switch to it, otherwise create a new one and switch to it
            if `git branch`.split("\n").any? { |b| b =~ /#{self.branch}/i }
              `git checkout #{self.branch}`
            else
              `git checkout -b #{self.branch}`
            end
          end

          def commit_branch(options='')
            message = add_signature_to_commit_message('Automated commit')

            `git add -A`
            `git commit --allow-empty -am "#{message}"`
            `git push #{options} origin #{self.branch}`
          end

        end
      end
    end
  end
end
