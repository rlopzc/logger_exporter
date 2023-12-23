Application.put_env(:logger, LoggerExporter, app_name: :test_app, environment_name: :test)

ExUnit.start()
