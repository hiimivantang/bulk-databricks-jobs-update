# bulk-databricks-jobs-update

1. Create `.netrc` with the following:
    ```
    machine <DATABRICKS_INSTANCE> 
    login token
    password <PERSONAL_ACCESS_TOKEN>
    ```
    For e.g. 
    ```
    machine abc-d1e2345f-a6b2.cloud.databricks.com
    login token
    password dapi1234567890ab1cde2f3ab456c7d89efa
    ```

2. (Optional) Update cluster specs found in `/clusters` 


3. Run the following to kickstart bulk update of your jobs: 
    ```
    ./bulk-job-clusters-change.sh https://abc-d1e2345f-a6b2.cloud.databricks.com
    ``` 

See demo:
[![asciicast](https://asciinema.org/a/487192.svg)](https://asciinema.org/a/487192)
