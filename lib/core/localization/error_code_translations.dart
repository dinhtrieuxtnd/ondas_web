const Map<String, String> kErrorCodeVi = {
  'success.ok': 'Thanh cong.',

  // Auth / Permission
  'error.unauthorized': 'Ban chua dang nhap.',
  'error.unauthorized.invalid_credentials': 'Sai email hoac mat khau.',
  'error.unauthorized.invalid_token': 'Token khong hop le.',
  'error.account_locked': 'Tai khoan da bi khoa.',
  'error.auth.current_password_invalid': 'Mat khau hien tai khong dung.',
  'error.forbidden': 'Ban khong co quyen truy cap.',
  'error.forbidden.playlist_access': 'Ban khong co quyen truy cap playlist nay.',

  // Not found
  'error.not_found': 'Khong tim thay du lieu.',
  'error.not_found.user': 'Khong tim thay nguoi dung.',
  'error.not_found.song': 'Khong tim thay bai hat.',
  'error.not_found.artist': 'Khong tim thay nghe si.',
  'error.not_found.album': 'Khong tim thay album.',
  'error.not_found.genre': 'Khong tim thay the loai.',
  'error.not_found.play_history': 'Khong tim thay lich su nghe.',
  'error.not_found.playlist': 'Khong tim thay playlist.',
  'error.not_found.playlist_song': 'Khong tim thay bai hat trong playlist.',
  'error.not_found.system_playlist': 'Khong tim thay playlist he thong.',
  'error.not_found.system_playlist_song': 'Khong tim thay bai hat trong playlist he thong.',
  'error.not_found.favorite': 'Khong tim thay muc yeu thich.',
  'error.not_found.lyrics': 'Khong tim thay lyrics.',
  'error.not_found.tag': 'Khong tim thay the.',

  // Conflict
  'error.conflict': 'Du lieu bi trung.',
  'error.conflict.email_exists': 'Email da ton tai.',
  'error.conflict.favorite_exists': 'Da ton tai trong yeu thich.',
  'error.conflict.playlist_song_exists': 'Bai hat da co trong playlist.',
  'error.conflict.system_playlist_song_exists':
      'Bai hat da co trong playlist he thong.',
  'error.conflict.lyrics_exists': 'Lyrics da ton tai.',
  'error.conflict.slug_exists': 'Slug da ton tai.',

  // Bad request / Business rule
  'error.bad_request': 'Yeu cau khong hop le.',
  'error.bad_request.invalid_body': 'Noi dung gui len khong hop le.',
  'error.bad_request.type_mismatch': 'Sai kieu du lieu.',
  'error.query.required': 'Thieu tham so truy van.',
  'error.song.audio_required': 'Thieu file audio.',
  'error.song.audio_source_not_found': 'Khong tim thay nguon audio.',
  'error.tag.ids_required': 'Thieu danh sach tag.',
  'error.playlist.visibility_invalid':
      'Gia tri quyen rieng tu playlist khong hop le.',
  'error.playlist.name_required': 'Ten playlist la bat buoc.',
  'error.playlist.name_too_long': 'Ten playlist qua dai.',
  'error.tag.name_exists': 'Ten tag da ton tai.',
  'error.tag.name_required': 'Ten tag la bat buoc.',
  'error.tag.type_required': 'Loai tag la bat buoc.',
  'error.tag.type_invalid': 'Loai tag khong hop le.',
  'error.playlist.reorder.invalid': 'Thu tu playlist khong hop le.',
  'error.system_playlist.reorder.invalid':
      'Thu tu playlist he thong khong hop le.',
  'error.lyrics.synced.invalid': 'Dinh dang lyrics synced khong hop le.',

  // System / Storage
  'error.storage.operation_failed': 'Thao tac luu tru that bai.',
  'error.internal': 'Loi he thong.',

  // Validation codes
  'validation.not_blank': 'khong duoc de trong',
  'validation.not_null': 'khong duoc null',
  'validation.not_empty': 'khong duoc rong',
  'validation.size.min': 'do dai toi thieu khong hop le',
  'validation.size.max': 'do dai toi da khong hop le',
  'validation.size.range': 'do dai khong hop le',
  'validation.email': 'khong dung dinh dang email',
  'validation.pattern': 'khong dung dinh dang',
  'validation.positive_or_zero': 'phai lon hon hoac bang 0',
  'validation.invalid_format': 'dinh dang khong hop le',
  'validation.type_mismatch': 'sai kieu du lieu',
  'validation.required': 'bat buoc',
};

const Map<String, String> kErrorCodeEn = {
  'success.ok': 'Success.',

  // Auth / Permission
  'error.unauthorized': 'Unauthorized.',
  'error.unauthorized.invalid_credentials': 'Invalid credentials.',
  'error.unauthorized.invalid_token': 'Invalid token.',
  'error.account_locked': 'Account is locked.',
  'error.auth.current_password_invalid': 'Current password is invalid.',
  'error.forbidden': 'Forbidden.',
  'error.forbidden.playlist_access':
      'You do not have access to this playlist.',

  // Not found
  'error.not_found': 'Not found.',
  'error.not_found.user': 'User not found.',
  'error.not_found.song': 'Song not found.',
  'error.not_found.artist': 'Artist not found.',
  'error.not_found.album': 'Album not found.',
  'error.not_found.genre': 'Genre not found.',
  'error.not_found.play_history': 'Play history not found.',
  'error.not_found.playlist': 'Playlist not found.',
  'error.not_found.playlist_song': 'Playlist song not found.',
  'error.not_found.system_playlist': 'System playlist not found.',
  'error.not_found.system_playlist_song': 'System playlist song not found.',
  'error.not_found.favorite': 'Favorite not found.',
  'error.not_found.lyrics': 'Lyrics not found.',
  'error.not_found.tag': 'Tag not found.',

  // Conflict
  'error.conflict': 'Conflict.',
  'error.conflict.email_exists': 'Email already exists.',
  'error.conflict.favorite_exists': 'Favorite already exists.',
  'error.conflict.playlist_song_exists': 'Song already in playlist.',
  'error.conflict.system_playlist_song_exists':
      'Song already in system playlist.',
  'error.conflict.lyrics_exists': 'Lyrics already exist.',
  'error.conflict.slug_exists': 'Slug already exists.',

  // Bad request / Business rule
  'error.bad_request': 'Bad request.',
  'error.bad_request.invalid_body': 'Invalid request body.',
  'error.bad_request.type_mismatch': 'Type mismatch.',
  'error.query.required': 'Missing query parameter.',
  'error.song.audio_required': 'Audio is required.',
  'error.song.audio_source_not_found': 'Audio source not found.',
  'error.tag.ids_required': 'Tag ids are required.',
  'error.playlist.visibility_invalid': 'Invalid playlist visibility.',
  'error.playlist.name_required': 'Playlist name is required.',
  'error.playlist.name_too_long': 'Playlist name is too long.',
  'error.tag.name_exists': 'Tag name already exists.',
  'error.tag.name_required': 'Tag name is required.',
  'error.tag.type_required': 'Tag type is required.',
  'error.tag.type_invalid': 'Invalid tag type.',
  'error.playlist.reorder.invalid': 'Invalid playlist order.',
  'error.system_playlist.reorder.invalid': 'Invalid system playlist order.',
  'error.lyrics.synced.invalid': 'Invalid synced lyrics format.',

  // System / Storage
  'error.storage.operation_failed': 'Storage operation failed.',
  'error.internal': 'Internal error.',

  // Validation codes
  'validation.not_blank': 'must not be blank',
  'validation.not_null': 'must not be null',
  'validation.not_empty': 'must not be empty',
  'validation.size.min': 'size is below minimum',
  'validation.size.max': 'size exceeds maximum',
  'validation.size.range': 'size is out of range',
  'validation.email': 'invalid email',
  'validation.pattern': 'invalid format',
  'validation.positive_or_zero': 'must be positive or zero',
  'validation.invalid_format': 'invalid format',
  'validation.type_mismatch': 'type mismatch',
  'validation.required': 'required',
};
