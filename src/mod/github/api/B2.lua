local Requests = require("mod.extlibs.api.Requests")
local Sha1 = require("mod.extlibs.api.Sha1")

local B2 = {}

local B2_KEY_ID = "000f5fce52c8be40000000004"
local B2_APPLICATION_KEY = "K000cr1Oey7ZNlX1XFx+aIDRnfJyGaw"
local B2_BUCKET_ID = "ef258f7cbee5c28c787b0e14"

local B2_AUTH_ENDPOINT = "https://api.backblazeb2.com/b2api/v2/b2_authorize_account"

local auth_params = nil

function B2.auth()
   local args = {
      auth = {
         _type = "basic",
         user = B2_KEY_ID,
         password = B2_APPLICATION_KEY
      }
   }

   local resp = Requests.get(B2_AUTH_ENDPOINT, args)

   if resp.status_code ~= 200 then
      return nil, resp.status_code
   end

   auth_params = resp.json()

   return auth_params, nil
end

function B2.upload_url(bucket_id)
   if auth_params == nil then
      local code, err
      auth_params, code, err = B2.auth()
      if not auth_params then
         return nil, code, err
      end
   end

   local args = {
      headers = {
         ["Authorization"] = auth_params["authorizationToken"]
      },
      params = {
         bucketId = bucket_id or B2_BUCKET_ID
      }
   }

   local url = ("%s/b2api/v2/b2_get_upload_url"):format(auth_params["apiUrl"])

   local resp = Requests.get(url, args)

   print(inspect(resp))

   if resp.status_code ~= 200 then
      return nil, resp.status_code, resp.text
   end

   return resp.json(), nil, nil
end

function B2.upload(file_data, file_name, content_type, upload_url, auth_token)
   if auth_params == nil then
      local code, err
      auth_params, code, err = B2.auth()
      if not auth_params then
         return nil, code, err
      end
   end

   if upload_url == nil then
      local upload_url_resp, code, err
      upload_url_resp, code, err = B2.upload_url()
      if not upload_url_resp then
         return nil, code, err
      end
      upload_url = upload_url_resp["uploadUrl"]
      auth_token = upload_url_resp["authorizationToken"]
   end

   local args = {
      headers = {
         ["X-Bz-Content-Sha1"] = Sha1.hex(file_data),
         ["X-Bz-File-Name"] = file_name,
         ["Authorization"] = auth_token,
         ["Content-Type"] = content_type or "b2/x-auto",
      },
      data = file_data
   }

   print(upload_url)
   local resp = Requests.post(upload_url, args)

   print(inspect(resp))

   if resp.status_code ~= 200 then
      return nil, resp.status_code, resp.text
   end

   return resp.json(), nil, nil
end

return B2
