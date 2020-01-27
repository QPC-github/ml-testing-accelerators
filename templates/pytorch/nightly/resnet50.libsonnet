local base = import "base.libsonnet";
local mixins = import "../../mixins.libsonnet";
local timeouts = import "../../timeouts.libsonnet";
local tpus = import "../../tpus.libsonnet";

{
  local resnet50 = base.PyTorchTest {
    modelName: "resnet50",
    command: [
      "python3",
      "pytorch/xla/test/test_train_imagenet.py",
      "--num_epochs=2",
      "--model=resnet50",
      "--num_workers=64",
      "--batch_size=128",
      "--log_steps=200",
      "--datadir=/datasets/imagenet",
    ],
    jobSpec+:: {
      template+: {
        spec+: {
          containers: [
            container {
              volumeMounts: [{
                mountPath: "/datasets",
                name: "datasets-pd",
              }],
              resources+: {
                requests: {
                  cpu: "90.0",
                  memory: "600Gi",
                },
              },
            } for container in super.containers
          ],
        },
      },
    },
  },
  local convergence = mixins.Convergence {
    accelerator+: tpus.Preemptible,
  },
  local v2_8 = {
    accelerator+: tpus.v2_8,
  },
  local v3_8 = {
    accelerator+: tpus.v3_8,
  },

  configs: [
    resnet50 + v2_8 + convergence + timeouts.Hours(23),
    resnet50 + v3_8 + convergence + timeouts.Hours(23),
  ],
}
