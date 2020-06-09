Docker image
------------

Build: 
```bash
cd docker && docker build -t smurfaderp/DeepCreamPy:latest . 
```

Run:
```bash
docker run \
    -v <input_path>:/opt/DeepCreamPy/decensor_input \
    -v <input_orginal_path>:/opt/DeepCreamPy/decensor_input_original \
    -v <output_path>:/opt/DeepCreamPy/decensor_output \
    smurfaderp/DeepCreamPy:latest
```
where
<input_path> - full path to input directory
<output_path> - full path to output directory
<input_orginal_path> - full path to original mosaic directory

