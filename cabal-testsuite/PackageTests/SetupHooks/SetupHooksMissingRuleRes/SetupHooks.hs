{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StaticPointers #-}

module SetupHooks where

import Distribution.Simple.LocalBuildInfo (interpretSymbolicPathLBI)
import Distribution.Simple.SetupHooks

import qualified Data.List.NonEmpty as NE ( NonEmpty(..) )

setupHooks :: SetupHooks
setupHooks =
  noSetupHooks
    { buildHooks =
        noBuildHooks
          { preBuildComponentRules = Just $ rules (static ()) missingResRules
          }
    }

missingResRules :: PreBuildComponentInputs -> RulesM ()
missingResRules (PreBuildComponentInputs { localBuildInfo = lbi, targetInfo = tgt }) = do
  let clbi = targetCLBI tgt
      i = interpretSymbolicPathLBI lbi
      autogenDir = i (autogenComponentModulesDir lbi clbi)
      action = mkCommand (static Dict) (static (\ _ -> return ())) ()
  registerRule_ "r" $
    staticRule action
      [ ]
      ( ( autogenDir, "G.hs" ) NE.:| [] )
