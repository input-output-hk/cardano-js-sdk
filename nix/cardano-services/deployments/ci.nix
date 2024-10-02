{
  lib,
  modules,
  config,
  ...
}: {
  imports = [
    modules.githubAction
  ];

  ci.github = {
    name = "cardano-services";
    deploymentAttrPath = config.ci.github.name;
    outputPath = "$PRJ_ROOT/.github/workflows/${config.ci.github.name}.yaml";
    extraDefinitions.permissions = {
      id-token = "write"; # This is required for AWS credentials action
      contents = "read";
    };
    extraSteps = lib.singleton {
      uses = "aws-actions/configure-aws-credentials@v4.0.2";
      "with" = {
        role-to-assume = "\${{ github.ref == 'refs/heads/master' && 'arn:aws:iam::926093910549:role/eks-admin' || 'arn:aws:iam::926093910549:role/eks-devs' }}";
        aws-region = "us-east-1";
      };
    };
  };
}
