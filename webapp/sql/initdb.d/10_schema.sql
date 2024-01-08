USE `isupipe`;

-- ユーザ (配信者、視聴者)
CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `display_name` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `dark_mode` BOOLEAN NOT NULL,
  UNIQUE `uniq_user_name` (`name`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- プロフィール画像
CREATE TABLE `icons` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `icon_hash` VARCHAR(255) NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE INDEX icons_user_id ON icons(user_id);

-- ライブ配信
CREATE TABLE `livestreams` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` text NOT NULL,
  `playlist_url` VARCHAR(255) NOT NULL,
  `thumbnail_url` VARCHAR(255) NOT NULL,
  `start_at` BIGINT NOT NULL,
  `end_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ライブ配信予約枠
CREATE TABLE `reservation_slots` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `slot` BIGINT NOT NULL,
  `start_at` BIGINT NOT NULL,
  `end_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ライブストリームに付与される、サービスで定義されたタグ
CREATE TABLE `tags` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  UNIQUE `uniq_tag_name` (`name`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ライブ配信とタグの中間テーブル
CREATE TABLE `livestream_tags` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `livestream_id` BIGINT NOT NULL,
  `tag_id` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE INDEX livestream_tags_livestream_id ON livestream_tags(`livestream_id`);

-- ライブ配信視聴履歴
CREATE TABLE `livestream_viewers_history` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `livestream_id` BIGINT NOT NULL,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ライブ配信に対するライブコメント
CREATE TABLE `livecomments` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `livestream_id` BIGINT NOT NULL,
  `comment` VARCHAR(255) NOT NULL,
  `tip` BIGINT NOT NULL DEFAULT 0,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE INDEX livecomments_livesream_id ON livecomments(livestream_id);

-- ユーザからのライブコメントのスパム報告
CREATE TABLE `livecomment_reports` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `livestream_id` BIGINT NOT NULL,
  `livecomment_id` BIGINT NOT NULL,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- 配信者からのNGワード登録
CREATE TABLE `ng_words` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `livestream_id` BIGINT NOT NULL,
  `word` VARCHAR(255) NOT NULL,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE INDEX ng_words_word ON ng_words(`word`);
CREATE INDEX ng_words_user_id_livestream_id ON ng_words(`user_id`, `livestream_id`);

-- ライブ配信に対するリアクション
CREATE TABLE `reactions` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `livestream_id` BIGINT NOT NULL,
  -- :innocent:, :tada:, etc...
  `emoji_name` VARCHAR(255) NOT NULL,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- ユーザごとに、紐づく配信について、累計リアクション数、累計ライブコメント数、累計売上金額を算出
CREATE TABLE `user_score` (
  `user_id` BIGINT NOT NULL,
  `total_reactions` BIGINT NOT NULL DEFAULT 0, -- ユーザの配信の累計リアクション数
  `total_tip` BIGINT NOT NULL DEFAULT 0, -- ユーザの配信の累計売上金額
  `total_livecomments` BIGINT NOT NULL DEFAULT 0, -- ユーザの配信への合計コメント数
  UNIQUE `uniq_user_id` (`user_id`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

DELIMITER //
-- insert default score
DROP TRIGGER IF EXISTS user_socre_user_trigger //
CREATE TRIGGER user_socre_user_trigger
AFTER INSERT ON users FOR EACH ROW
  INSERT INTO user_score (user_id) VALUES (NEW.id) //

-- update user_score when new reaction is inserted
DROP TRIGGER IF EXISTS user_score_reaction_trigger //
CREATE TRIGGER user_score_reaction_trigger
AFTER INSERT ON reactions FOR EACH ROW
BEGIN
  DECLARE uid, current_count BIGINT;

  SELECT
    `user_id`,`total_reactions` INTO uid,current_count
  FROM user_score
  WHERE user_id=(
      SELECT l.user_id
      FROM livestreams l
      WHERE l.id=NEW.livestream_id
    );

  UPDATE user_score SET `total_reactions`=current_count+1 WHERE `user_id`=uid;
END //

DROP TRIGGER IF EXISTS user_score_livecomment_trigger //
CREATE TRIGGER user_score_livecomment_trigger
AFTER INSERT ON livecomments FOR EACH ROW
BEGIN
  DECLARE uid,current_tip,current_comments  BIGINT;

  SELECT
      user_id,total_tip,total_livecomments INTO uid,current_tip,current_comments
  FROM user_score
  WHERE user_id=(
      SELECT user_id
      FROM livestreams
      WHERE id=NEW.livestream_id
    );

  UPDATE user_score
  SET
    total_tip=current_tip+NEW.tip,
    total_livecomments=current_comments+1
  WHERE user_id=uid;
END //
DELIMITER ;
