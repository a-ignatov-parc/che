#### Logger
#
#

define ["logWriter"], () ->


  return {
    log: _log
    info: _info
    warn: warn
    error: error    
  }