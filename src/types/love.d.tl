local love = record
  filesystem = record
      FileType = enum
          "file"
          "directory"
          "symlink"
          "other"
      end

      FileInfo = record
         type: FileType
         size: number
         modtime: number
      end

      getWorkingDirectory: function(): string
      isFile: function(string): boolean
      isDirectory: function(string): boolean
      exists: function(string): boolean
      getInfo: function(string): FileInfo
      getDirectoryItems: function(string): function():(string)
      remove: function(string): boolean
      write: function(string, string): boolean
      read: function(string): table
      getSaveDirectory: function(): string
      createDirectory: function(string): boolean
   end

  getVersion: function(): string
end

return love
