from IPFSupload import IPFSUploadStorage



if __name__ == '__main__':
    token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweGNkRmVFOTMzNzRkZTQ0QjZkMTljMDhGZGM4MmVCNGJCZTc0N0QzRGEiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTY1NzI5NTM1ODkzMywibmFtZSI6IklQRlMtQVBJIn0.Axl3ArtYlS0qofCRSey6IvEy9DjQwOvun-vlWWoLHFA"
    IPFSUploadStorage().register(token, api=None)
    upload = IPFSUploadStorage()

    # test check cid if exist
    check_cid = upload.check_if_cid_exist(i)
    print("check_cid", check_cid)

    # test upload_direct
    upload_direct = upload.upload_direct("./rabbit.png")
    print("upload_direct", upload_direct)

    # test delete cid
    delete_cid = upload.delete_cid("bafkreid2ie247qyhnd6qhecrutg5bxplzdewxnabn5rhbjfdvsdtsnrieq")
    print("delete_cid", delete_cid)
