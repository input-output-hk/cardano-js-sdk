% Yarn constraints for supply-chain enforcement (`yarn constraints`).
%
% The Sept-2025 qix-hack malicious-version blocklist that previously lived
% here has been removed: those releases are unpublished from npm (404) and
% the affected packages now resolve to clean current versions, so the
% blocklist no longer matches anything.
%
% Add `gen_enforced_dependency` rules below to block future malicious
% releases or pin known-good versions, e.g.:
%
%   gen_enforced_dependency ForbidMaliciousReleases:
%     some-package "!=1.2.3"
