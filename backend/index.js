import AWS from "aws-sdk";

const autoscaling = new AWS.AutoScaling();
const rds = new AWS.RDS();

export const handler = async () => {
  try {
    // ASG
    const asgData = await autoscaling
      .describeAutoScalingGroups()
      .promise();

    const group = asgData.AutoScalingGroups[0];

    const ec2Count = group.Instances.length;
    const desired = group.DesiredCapacity;

    // RDS
    const rdsData = await rds.describeDBInstances().promise();
    const dbStatus = rdsData.DBInstances[0].DBInstanceStatus;

    return {
      statusCode: 200,
      body: JSON.stringify({
        status: "ok",
        ec2: {
          running: ec2Count,
          desired: desired,
        },
        rds: dbStatus,
      }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        status: "error",
        message: error.message,
      }),
    };
  }
};