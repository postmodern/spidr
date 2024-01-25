# frozen_string_literal: true

module Spidr
  #
  # Represents HTTP Authentication credentials for a website.
  #
  class AuthCredential

    # The username
    attr_reader :username

    # The password
    attr_reader :password

    #
    # Creates a new credential used for authentication.
    #
    # @param [String] username
    #   The username for the credential.
    #
    # @param [String] password
    #   The password for the credential.
    #
    def initialize(username,password)
      @username = username
      @password = password
    end

  end
end
