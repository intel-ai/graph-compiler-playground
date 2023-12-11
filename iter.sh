export ONEDNN_VERBOSE=1

if [[ -z "${DL_BENCH_ARGS}" ]]; then
  echo "Please, provide DATASETS_PWD environment variable"
  exit 1
fi

CNNS=(vgg1 resnet50 resnext50 resnext101 densenet121 efficientnet_v2m mobilenet_v3_large)
for name in "${CNNS[@]}"
do
    echo "Benchmark $name"
    benchmark-run -b cnn -p "name='${name}',batch_size=32" --benchmark_desc "${size}_bs32" ${DL_BENCH_ARGS} || echo Failed
done

echo "Bfloat16 on size5"
benchmark-run -b mlp -p "name='size5',batch_size=1024" --benchmark_desc "size5_bs1024_bfloat16" --dtype bfloat16 ${DL_BENCH_ARGS} || echo Failed

# for size in size5_bn_gelu
for size in size2 size3 size4 size5 size5_sigm size5_tanh size5_gelu size5_linear size5_inplace size5_bn size5_bn_gelu size5_drop_gelu 100@512 25@1024 4@16384 2@16384
do
    echo "Benchmark $size"
    benchmark-run -b mlp -p "name='${size}'" --benchmark_desc "${size}_bs1024" ${DL_BENCH_ARGS} || echo Failed
done

size="size5"
for BATCH_SIZE in 1 16 256 2048 8196
do
    echo "Batch size $BATCH_SIZE"
    echo "Benchmark $size"
    BATCH_SIZE_TXT=$(printf "%04d" $BATCH_SIZE)
    benchmark-run -b mlp -p "name='${size}',batch_size=${BATCH_SIZE}" --benchmark_desc "${size}_bs${BATCH_SIZE_TXT}" ${DL_BENCH_ARGS} || echo Failed
done