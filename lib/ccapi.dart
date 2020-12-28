/// Ferqo CC GW local software develop development kit
///
/// ## Connect with CC GW
///
/// The listen port in the gateway is 11188, all the packets between App and
/// gateway are using the structure LOCAL_SDK_FORMAT_T, in the first stage the
/// packet is not encrypted and checksum not used.
/// The App will set magic_id=0x88 in all the packet.
///
library ccapi;

// export 'ccapi/';

// TODO: Export any libraries intended for clients of this package.
