import requests
from typing import Optional, Any, Union
import json


class IPFSUploadStorage(object):
    """
    NFT.Storage 的HTTP API只支持上传单个文件，不能上传目录
    """
    access_token: str
    configuration: str
    nft_storage_api: str

    @classmethod
    def register(cls, api_token, api=Optional[str]):
        """
        :param api_token: Your nft.storage API KEY
        :param api: nft.storage api
        """
        if not api_token:
            raise ValueError("Please check your token")

        if not api:
            cls.nft_storage_api = "https://api.nft.storage/"
        else:
            cls.nft_storage_api = api
        cls.access_token = api_token

    @property
    def template_headers(self) -> dict:
        return {'accept': "application/json", 'Authorization': IPFSUploadStorage.access_token}

    def upload_direct(self, dir_path: Union[str]):
        """
        :param dir_path: upload direct
        """
        header = self.template_headers
        header.update({"Content-Type": "image/png"})
        header.update({"Content-Disposition": 'form-data; name="file"; filename="image.png"'})

        files = {"file": open(dir_path, "rb")}

        return IPFSUploadStorage._request_wrapper(
            header=header,
            host="{}{}".format(
                IPFSUploadStorage.nft_storage_api,
                "/upload"),
            files=files,
            method="post").json()

    def check_if_cid_exist(self, cid=None):
        """
        :param cid: check_cid
        :return: if cid exist, 'ok':True
        """
        template_cid = "bafybeicx7wnduutyvvyt2za5cvm4mp6pliupnslkf2ftljd23t3rbwfkmy"
        response = IPFSUploadStorage._request_wrapper(
            header=self.template_headers,
            host="{}{}".format(
                IPFSUploadStorage.nft_storage_api,
                f"check/{cid or template_cid}"), ).json()
        return response

    def delete_cid(self, cid: Union[str]):
        if not self.check_if_cid_exist(cid)['ok']:
            raise ValueError("Cid is not exist")

        response = IPFSUploadStorage._request_wrapper(
            header=self.template_headers,
            host="{}{}".format(IPFSUploadStorage.nft_storage_api, cid),
            method="delete")

        try:
            return response.json()
        except json.decoder.JSONDecodeError as e:
            return {"code": response.status_code, "message": e}

    @staticmethod
    def _request_wrapper(
            header,
            host: Optional[str],
            files: Optional[Any] = None,
            method: Optional[str] = None,
            **kwargs
    ):
        try:
            if not method or "get" in method:
                response = requests.get(
                    url=host or IPFSUploadStorage.nft_storage_api,
                    headers=header,
                    params=kwargs)
                return response
            if "post" in method:
                response = requests.post(url=host, headers=header, data=files)
                return response
            if "delete" in method:
                response = requests.delete(url=host, headers=header)
                return response
        except requests.exceptions as e:
            return {"code": 500, "message": e}


