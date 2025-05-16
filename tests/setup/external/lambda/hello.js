module.exports.handler = async () => {
  const version = process.env.AWS_LAMBDA_FUNCTION_VERSION;
  console.log('Lambda version:', version);

  return {
    statusCode: 200,
    body: JSON.stringify({ version }),
  };
};
