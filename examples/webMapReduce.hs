{-# LANGUAGE   CPP #-}

module Main where

import Prelude hiding (div,id)
import Transient.Internals ((!>))
import Transient.Base

#ifdef ghcjs_HOST_OS
   hiding ( option)
#endif
import GHCJS.HPlay.View
#ifdef ghcjs_HOST_OS
   hiding (map)
#else
   hiding (map, option)
#endif

import Transient.Move
import Transient.Logged
import Control.Applicative
import Control.Monad
import Data.Typeable
import Data.IORef
import Control.Concurrent (threadDelay)
import Control.Monad.IO.Class
import qualified Data.Vector as V
import qualified Data.Map as M


import Transient.MapReduce







-- A Web node launch a map-reduce in all the server nodes, getting data from a
-- web node from a textbox imput and render the returned results

main =   simpleWebApp 8080 app


app= do

    content <-  local . render $
                    textArea  (fs "") ! atr "placeholder" (fs "enter the content")
                                      ! atr "rows" (fs "4")
                                      ! atr "cols" (fs "80")
                                 `fire` OnChange
                     <++ br
                     <** inputSubmit "send"  -- `fire` OnClick

    r <- atRemote $ do
               lliftIO $ print content
               r<- reduce  (+)
                    . mapKeyB (\w -> (w, 1 :: Int))
                    $ getText  words content
               lliftIO $ print r
               return (r :: M.Map String Int)


    local . render $ rawHtml $do
                 h1 "Results"
                 mconcat[i "word " >> b w >> i " appears " >> b n >> i "times" >> br
                        | (w,n) <- M.assocs r]

fs= toJSString

