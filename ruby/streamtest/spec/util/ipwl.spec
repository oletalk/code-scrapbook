require 'spec_helper'

describe '::action' do

    it 'should block any IP given default action is block and empty list' do
        x = IPWhitelist.new({}, { allow: false} )
        expect(x.action('192.168.0.1')).to eq({ allow: false })
    end

    it 'should allow an IP we specify is to be allowed' do
        x = IPWhitelist.new({'192.168.0.1' => { allow: true }}, { allow: false} )
        expect(x.action('192.168.0.1')).to eq({ allow: true , downsample: false})
    end

    it 'should deny an IP outside the allow range we specified' do
        x = IPWhitelist.new({'192.168.0.1' => { allow: true }}, { allow: false} )
        expect(x.action('192.168.0.2')).to eq({ allow: false })
    end

    it 'should allow an IP within one of the ranges we specified' do
        x = IPWhitelist.new({'192.168.0.1' => { allow: true },
                             '192.168.0.4' => { allow: true }}, { allow: false} )
        expect(x.action('192.168.0.4')).to eq({ allow: true, downsample: false })
    end

    it 'should accept an IP range' do
        x = IPWhitelist.new({'192.168.0.0/24' => { allow: true }}, { allow: false } )
        expect(x.action('192.168.0.21')).to eq({ allow: true, downsample: false })
        expect(x.action('127.0.0.1')).to eq({ allow: false })
    end

    it 'should allow extra attributes to be specified' do
        x = IPWhitelist.new({'192.168.0.1' => { allow: true, downsample: true }, 
                             '192.168.0.2' => { allow: true, downsample: false }}, { allow: false })
        expect(x.action('192.168.0.1')[:downsample]).to eq(true)
        expect(x.action('192.168.0.2')[:downsample]).to eq(false)
    end
end

