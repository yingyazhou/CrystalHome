class: Workflow
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
steps:
  - id: download_s3
    in:
      - id: s3_path
        source: s3_path
      - id: update_lib_dummy
        source: update_lib/output_dummy
    out:
      - id: output_zip
    run:
      class: CommandLineTool
      cwlVersion: v1.0
      $namespaces:
        sbg: 'https://www.sevenbridges.com/'
      id: download_s3
      baseCommand:
        - /fastone/bin/froms3download.bat
      inputs:
        - id: s3_path
          type: string
          inputBinding:
            position: 0
            shellQuote: false
          label: 's3://<bucket>/<path>'
        - id: update_lib_dummy
          type: string?
      outputs:
        - id: output_zip
          type: File?
          outputBinding:
            glob: '*.zip'
      label: download_s3
    label: download_s3
    'sbg:x': 226
    'sbg:y': 187.5
  - id: update_lib
    in:
      - id: input_dummy
        source: s3_path
    out:
      - id: output_dummy
    run:
      class: CommandLineTool
      cwlVersion: v1.0
      $namespaces:
        sbg: 'https://www.sevenbridges.com/'
      id: update_lib
      baseCommand:
        - /fastone/bin/update-lib.bat
      inputs:
        - id: input_dummy
          type: string?
      outputs:
        - id: output_dummy
          type: string?
          outputBinding:
            glob: .
            outputEval: '$(self[0].path)'
      label: update-lib
      requirements:
        - class: InlineJavascriptRequirement
    label: update-lib
    'sbg:x': 86
    'sbg:y': 115
  - id: unzip
    in:
      - id: input
        source: download_s3/output_zip
    out:
      - id: workDir
      - id: workDir1
      - id: jobs
    run:
      class: CommandLineTool
      cwlVersion: v1.0
      $namespaces:
        sbg: 'https://www.sevenbridges.com/'
      id: unzip
      baseCommand:
        - /fastone/bin/unzip.bat
      inputs:
        - id: input
          type: File
          inputBinding:
            position: 0
            shellQuote: false
          label: testBundle
          doc: The bladed test bundle
      outputs:
        - id: workDir
          type: string
          outputBinding:
            loadContents: true
            glob: ./FASTONE.WDIR
            outputEval: '$(self[0].contents.trim())'
        - id: workDir1
          type: Directory
          outputBinding:
            glob: .
        - id: jobs
          type: 'File[]'
          outputBinding:
            glob: batch/Jobs/job*/dtbladed.in
      label: unzip
        - class: InlineJavascriptRequirement
    label: unzip
    'sbg:x': 353
    'sbg:y': 168
  - id: run_bladed
    in:
      - id: dummy
        source: patch_jobs/dummy
      - id: job
        source: unzip/jobs
    out:
      - id: bladed_dummy
    run:
      class: CommandLineTool
      cwlVersion: v1.0
      $namespaces:
        sbg: 'https://www.sevenbridges.com/'
      id: run_bladed
      baseCommand:
        - /fastone/bin/run-bladed.bat
      inputs:
        - id: dummy
          type: string
        - id: job
          type: File
          inputBinding:
            position: 0
            shellQuote: false
      outputs:
        - id: bladed_dummy
          type: string
          outputBinding:
            glob: .
            outputEval: '$(self[0].path)'
      label: run-bladed
      requirements:
        - class: ResourceRequirement
          coresMin: 1
        - class: InlineJavascriptRequirement
    label: run-bladed
    scatter:
      - job
    'sbg:x': 668
    'sbg:y': 314
  - id: uploadtos3
    in:
      - id: uploadtos3_Directory
        source: unzip/workDir1
      - id: input_dummy
        source:
          - run_bladed/bladed_dummy
    out: []
    run:
      class: CommandLineTool
      cwlVersion: v1.0
      $namespaces:
        sbg: 'https://www.sevenbridges.com/'
      id: uploadtos3
      baseCommand:
        - /fastone/bin/uploadtos3.bat
      inputs:
        - id: uploadtos3_Directory
          type: Directory
          inputBinding:
            position: 0
            shellQuote: false
        - id: input_dummy
          type: 'string[]?'
      outputs: []
      label: uploadtos3
    label: uploadtos3
    'sbg:x': 829
    'sbg:y': 129
  - id: patch_jobs
    in:
      - id: input
        source: unzip/workDir
    out:
      - id: dummy
    run:
      class: CommandLineTool
      cwlVersion: v1.0
      $namespaces:
        sbg: 'https://www.sevenbridges.com/'
      id: patch_jobs
      baseCommand:
        - /fastone/bin/patch-jobs.bat
      inputs:
        - id: input
          type: string?
          inputBinding:
            position: 0
            shellQuote: false
      outputs:
        - id: dummy
          type: string
          outputBinding:
            glob: .
            outputEval: '$(self[0].path)'
      label: patch-jobs
      requirements:
        - class: InlineJavascriptRequirement
    label: patch-jobs
    'sbg:x': 523
    'sbg:y': 330
hints:
  - class: CloudRequirement
    image: bladed-compute-0527
  - class: SchedulerRequirement
    scheduler: PBS_PRO_WINDOWS
requirements:
  - class: ScatterFeatureRequirement
