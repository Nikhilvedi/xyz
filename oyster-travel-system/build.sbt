// Root project definition for Oyster-style Travel System
// This is a multi-module SBT project demonstrating functional programming in Scala

// Global settings that apply to all modules
ThisBuild / version := "0.1.0-SNAPSHOT"
ThisBuild / scalaVersion := "2.13.12"
ThisBuild / organization := "com.oyster"

// Common settings for all modules
lazy val commonSettings = Seq(
  scalacOptions ++= Seq(
    "-deprecation",           // Emit warning and location for usages of deprecated APIs
    "-encoding", "utf-8",     // Specify character encoding used by source files
    "-feature",               // Emit warning and location for usages of features that should be imported explicitly
    "-unchecked",             // Enable additional warnings where generated code depends on assumptions
    "-Xlint:_",              // Enable all available lint warnings
    "-Ywarn-dead-code",      // Warn when dead code is identified
    "-Ywarn-value-discard"   // Warn when non-Unit expression results are unused
  ),
  libraryDependencies ++= Seq(
    // Functional programming libraries
    "org.typelevel" %% "cats-core" % "2.10.0",
    "org.typelevel" %% "cats-effect" % "3.5.2",
    
    // Testing libraries
    "org.scalatest" %% "scalatest" % "3.2.17" % Test,
    "org.scalatestplus" %% "scalacheck-1-17" % "3.2.17.0" % Test,
    "org.typelevel" %% "cats-effect-testing-scalatest" % "1.5.0" % Test
  )
)

// Root project - aggregates all modules
lazy val root = (project in file("."))
  .settings(
    name := "oyster-travel-system",
    commonSettings
  )
  .aggregate(
    domain,
    accountService,
    walletService,
    tapValidation,
    operations,
    demo,
    api
  )

// Domain module - contains core business logic and models
// This module defines the fundamental types and business rules using functional programming
lazy val domain = (project in file("modules/domain"))
  .settings(
    name := "domain",
    commonSettings,
    libraryDependencies ++= Seq(
      // JSON serialization
      "io.circe" %% "circe-core" % "0.14.6",
      "io.circe" %% "circe-generic" % "0.14.6",
      "io.circe" %% "circe-parser" % "0.14.6"
    )
  )

// Account Service module - handles account creation and card ordering
// Depends on domain for core types
lazy val accountService = (project in file("modules/account-service"))
  .settings(
    name := "account-service",
    commonSettings
  )
  .dependsOn(domain)

// Wallet Service module - manages wallet top-ups and balance
// Depends on domain for core types
lazy val walletService = (project in file("modules/wallet-service"))
  .settings(
    name := "wallet-service",
    commonSettings
  )
  .dependsOn(domain)

// Tap Validation module - handles tap-in/tap-out and fare calculation
// Depends on domain for core types and walletService for balance operations
lazy val tapValidation = (project in file("modules/tap-validation"))
  .settings(
    name := "tap-validation",
    commonSettings
  )
  .dependsOn(domain, walletService)

// Operations module - provides operational tooling and monitoring
// Depends on all other modules to provide comprehensive system oversight
lazy val operations = (project in file("modules/operations"))
  .settings(
    name := "operations",
    commonSettings
  )
  .dependsOn(domain, accountService, walletService, tapValidation)

// Demo application - demonstrates system usage with example scenarios
// Depends on all modules to showcase complete functionality
lazy val demo = (project in file("modules/demo"))
  .settings(
    name := "demo",
    commonSettings
  )
  .dependsOn(domain, accountService, walletService, tapValidation, operations)

// API module - Play Framework REST API
// Provides HTTP endpoints for all system operations
lazy val api = (project in file("modules/api"))
  .enablePlugins(PlayScala)
  .settings(
    name := "api",
    commonSettings,
    libraryDependencies ++= Seq(
      guice,
      "com.typesafe.play" %% "play-json" % "2.9.4",
      "org.scalatestplus.play" %% "scalatestplus-play" % "5.1.0" % Test
    )
  )
  .dependsOn(domain, accountService, walletService, tapValidation, operations)
