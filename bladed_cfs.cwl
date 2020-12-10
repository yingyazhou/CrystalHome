cwlVersion: v1.0
id: bladed_s3
label: bladed_s3
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: s3_path
    type: string
    label: 's3://<bucket>/<path>'
    'sbg:x': -54
    'sbg:y': 195
outputs:
  - id: workDir1
    outputSource:
      - unzip/workDir1
    type: Directory
    'sbg:x': 722
    'sbg:y': 0