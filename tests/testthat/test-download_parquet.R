test_that("download_parquet endpoints work", {
  with_mock_dir("parquet", {
    # data summary
    summary <- download_eea_summary()
    expect_type(summary, "list")
    expect_named(summary, c("numberFiles", "size"))

    # urls
    urls <- download_eea_parquet_urls()
    expect_vector(urls)
    expect_type(urls, "character")

    # async
    async <- download_eea_parquet_async()
    expect_vector(async, size = 1)
    expect_type(async, "character")

    # files
    files <- download_eea_parquet_files()
    expect_vector(files, size = 1)
    expect_type(files, "character")
  })
})
