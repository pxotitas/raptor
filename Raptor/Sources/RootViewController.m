
#import "RootViewController.h"

static UIColor *RaptorRed(void) {
    return [UIColor colorWithRed:0.88 green:0.08 blue:0.12 alpha:1.0];
}
static UIColor *RaptorInk(void) {
    return [UIColor colorWithRed:0.12 green:0.13 blue:0.15 alpha:1.0];
}

@interface RaptorVideo : NSObject
@property(nonatomic, copy) NSString *videoID;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *author;
@property(nonatomic, copy) NSString *thumbnail;
@end
@implementation RaptorVideo
@end

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property(nonatomic, strong) UIView *header;
@property(nonatomic, strong) UILabel *brand;
@property(nonatomic, strong) UIImageView *brandIcon;
@property(nonatomic, strong) UISearchBar *search;
@property(nonatomic, strong) UIView *playerHost;
@property(nonatomic, strong) UILabel *playerPlaceholder;
@property(nonatomic, strong) UILabel *status;
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) NSMutableArray *videos;
@property(nonatomic, strong) NSURLSessionDataTask *searchTask;
@property(nonatomic, assign) NSUInteger searchGeneration;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    self.videos = [NSMutableArray array];
    [self buildInterface];
    self.status.text = @"Pesquise um vídeo para começar";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat top = 0.0;
    CGFloat headerHeight = 56.0;
    self.header.frame = CGRectMake(0, top, width, headerHeight);
    self.brand.frame = CGRectMake(62, 7, width - 78, 42);
    self.brandIcon.frame = CGRectMake(14, 8, 40, 40);
    self.search.frame = CGRectMake(0, headerHeight, width, 52);

    CGFloat playerY = CGRectGetMaxY(self.search.frame);
    CGFloat playerHeight = MIN(width * 9.0 / 16.0, CGRectGetHeight(self.view.bounds) * 0.48);
    self.playerHost.frame = CGRectMake(0, playerY, width, playerHeight);
    self.playerPlaceholder.frame = self.playerHost.bounds;

    CGFloat statusY = CGRectGetMaxY(self.playerHost.frame);
    self.status.frame = CGRectMake(14, statusY, width - 28, 34);
    CGFloat tableY = CGRectGetMaxY(self.status.frame);
    self.table.frame = CGRectMake(0, tableY, width, MAX(0, CGRectGetHeight(self.view.bounds) - tableY));
}

- (void)buildInterface {
    self.header = [[UIView alloc] initWithFrame:CGRectZero];
    self.header.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.header];

    self.brandIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RaptorMark"]];
    self.brandIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.header addSubview:self.brandIcon];
    self.brand = [[UILabel alloc] initWithFrame:CGRectZero];
    self.brand.text = @"RAPTOR";
    self.brand.font = [UIFont boldSystemFontOfSize:25.0];
    self.brand.textColor = RaptorRed();
    [self.header addSubview:self.brand];

    self.search = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.search.delegate = self;
    self.search.placeholder = @"Pesquisar no YouTube";
    self.search.searchBarStyle = UISearchBarStyleMinimal;
    self.search.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.search.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:self.search];

    self.playerHost = [[UIView alloc] initWithFrame:CGRectZero];
    self.playerHost.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerHost];

    self.playerPlaceholder = [[UILabel alloc] initWithFrame:CGRectZero];
    self.playerPlaceholder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.playerPlaceholder.text = @"🦖  RAPTOR PLAYER";
    self.playerPlaceholder.textColor = [UIColor colorWithWhite:0.78 alpha:1.0];
    self.playerPlaceholder.font = [UIFont boldSystemFontOfSize:18.0];
    self.playerPlaceholder.textAlignment = NSTextAlignmentCenter;
    [self.playerHost addSubview:self.playerPlaceholder];

    self.status = [[UILabel alloc] initWithFrame:CGRectZero];
    self.status.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    self.status.textColor = [UIColor grayColor];
    self.status.font = [UIFont systemFontOfSize:12.0];
    self.status.text = @"Pronto";
    [self.view addSubview:self.status];

    self.table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.table.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    self.table.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.rowHeight = 94.0;
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.table];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self searchFor:searchBar.text];
}

- (void)searchFor:(NSString *)query {
    NSString *cleanQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (cleanQuery.length == 0) { self.status.text = @"Digite algo para pesquisar"; return; }
    [self.searchTask cancel];
    NSUInteger generation = ++self.searchGeneration;
    self.status.text = @"Conectando ao YouTube…";
    [self.videos removeAllObjects];
    [self.table reloadData];

    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://www.youtube.com/results"];
    components.queryItems = @[[NSURLQueryItem queryItemWithName:@"search_query" value:cleanQuery]];
    NSURL *url = components.URL;
    if (!url) { self.status.text = @"Não consegui preparar a pesquisa"; return; }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:35.0];
    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [request setValue:@"pt-BR,pt;q=0.9,en;q=0.7" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"https://www.youtube.com/" forHTTPHeaderField:@"Referer"];
    [request setValue:@"Mozilla/5.0 (iPad; CPU OS 9_3_5 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13G36 Safari/601.1" forHTTPHeaderField:@"User-Agent"];

    self.searchTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (generation != self.searchGeneration) return;
        NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
        NSMutableArray *found = [NSMutableArray array];
        NSString *message = nil;

        if (error || !data) {
            message = [NSString stringWithFormat:@"Falha na conexão: %@",
                       error.localizedDescription ?: @"sem resposta"];
        } else if ([http isKindOfClass:[NSHTTPURLResponse class]] && http.statusCode >= 400) {
            message = [NSString stringWithFormat:@"YouTube respondeu HTTP %ld", (long)http.statusCode];
        } else {
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (!html) html = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
            NSString *marker = @"var ytInitialData = ";
            NSRange markerRange = [html rangeOfString:marker];
            if (markerRange.location != NSNotFound) {
                NSUInteger start = NSMaxRange(markerRange);
                NSRange end = [html rangeOfString:@";</script>" options:0
                    range:NSMakeRange(start, html.length - start)];
                if (end.location != NSNotFound) {
                    NSString *jsonText = [html substringWithRange:NSMakeRange(start, end.location - start)];
                    NSData *jsonData = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *parseError = nil;
                    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
                    if (json) [self collectVideos:json into:found];
                    else message = @"O YouTube mudou o formato dos resultados.";
                } else message = @"A resposta do YouTube veio incompleta.";
            } else if ([html rangeOfString:@"consent.youtube.com"].location != NSNotFound ||
                       [html rangeOfString:@"Before you continue"].location != NSNotFound) {
                message = @"O YouTube pediu confirmação de consentimento.";
            } else message = @"Não encontrei os dados de pesquisa na página do YouTube.";
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation != self.searchGeneration) return;
            [self.videos addObjectsFromArray:found];
            [self.table reloadData];
            self.status.text = found.count
                ? [NSString stringWithFormat:@"%lu vídeos encontrados", (unsigned long)found.count]
                : (message ?: @"Nenhum vídeo encontrado.");
        });
    }];
    [self.searchTask resume];
}

- (NSString *)textFromRuns:(id)value {
    if (![value isKindOfClass:[NSDictionary class]]) return nil;
    NSDictionary *dictionary = value;
    NSString *simple = [dictionary[@"simpleText"] isKindOfClass:[NSString class]] ? dictionary[@"simpleText"] : nil;
    if (simple.length) return simple;
    NSArray *runs = [dictionary[@"runs"] isKindOfClass:[NSArray class]] ? dictionary[@"runs"] : nil;
    NSMutableArray *parts = [NSMutableArray array];
    for (id run in runs) {
        if ([run isKindOfClass:[NSDictionary class]] && [run[@"text"] isKindOfClass:[NSString class]])
            [parts addObject:run[@"text"]];
    }
    return parts.count ? [parts componentsJoinedByString:@""] : nil;
}

- (void)collectVideos:(id)object into:(NSMutableArray *)output {
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = object;
        NSDictionary *renderer = [dictionary[@"videoRenderer"] isKindOfClass:[NSDictionary class]]
            ? dictionary[@"videoRenderer"] : nil;
        if (renderer && [renderer[@"videoId"] isKindOfClass:[NSString class]]) {
            NSString *videoID = renderer[@"videoId"];
            NSCharacterSet *valid = [NSCharacterSet characterSetWithCharactersInString:
                @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"];
            if (videoID.length < 6 || videoID.length > 20 ||
                [videoID rangeOfCharacterFromSet:[valid invertedSet]].location != NSNotFound) return;
            for (RaptorVideo *existing in output)
                if ([existing.videoID isEqualToString:videoID]) return;

            RaptorVideo *video = [[RaptorVideo alloc] init];
            video.videoID = videoID;
            video.title = [self textFromRuns:renderer[@"title"]] ?: @"Vídeo do YouTube";
            video.author = [self textFromRuns:renderer[@"ownerText"]] ?:
                ([self textFromRuns:renderer[@"longBylineText"]] ?: @"YouTube");

            NSArray *thumbnails = [renderer[@"thumbnail"][@"thumbnails"] isKindOfClass:[NSArray class]]
                ? renderer[@"thumbnail"][@"thumbnails"] : nil;
            NSDictionary *best = nil;
            NSInteger bestWidth = 0;
            for (id item in thumbnails) {
                if (![item isKindOfClass:[NSDictionary class]]) continue;
                NSInteger width = [item[@"width"] respondsToSelector:@selector(integerValue)]
                    ? [item[@"width"] integerValue] : 0;
                if ([item[@"url"] isKindOfClass:[NSString class]] && width >= bestWidth) {
                    best = item; bestWidth = width;
                }
            }
            video.thumbnail = [best[@"url"] isKindOfClass:[NSString class]] ? best[@"url"] : nil;
            [output addObject:video];
            return;
        }
        for (id child in dictionary.allValues) [self collectVideos:child into:output];
    } else if ([object isKindOfClass:[NSArray class]]) {
        for (id child in object) [self collectVideos:child into:output];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"RaptorVideoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:reuseIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.textLabel.textColor = RaptorInk();
        cell.textLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.frame = CGRectMake(0, 0, 120, 68);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    RaptorVideo *video = self.videos[indexPath.row];
    cell.textLabel.text = video.title;
    cell.detailTextLabel.text = video.author;
    cell.imageView.image = nil;
    cell.tag = (NSInteger)indexPath.row;

    if (video.thumbnail.length) {
        NSURL *thumbnailURL = [NSURL URLWithString:video.thumbnail];
        if (thumbnailURL) {
            [[[NSURLSession sharedSession] dataTaskWithURL:thumbnailURL
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!data || error) return;
                UIImage *image = [UIImage imageWithData:data];
                if (!image) return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UITableViewCell *visibleCell = [tableView cellForRowAtIndexPath:indexPath];
                    if (visibleCell && visibleCell.tag == (NSInteger)indexPath.row &&
                        indexPath.row < self.videos.count &&
                        [[((RaptorVideo *)self.videos[indexPath.row]) videoID] isEqualToString:video.videoID]) {
                        visibleCell.imageView.image = image;
                        [visibleCell setNeedsLayout];
                    }
                });
            }] resume];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.videos.count) return;
    RaptorVideo *video = self.videos[indexPath.row];

    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:
                               @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"];
    if ([video.videoID rangeOfCharacterFromSet:[allowed invertedSet]].location != NSNotFound) {
        self.status.text = @"ID de vídeo inválido";
        return;
    }

    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.playerHost.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.backgroundColor = [UIColor blackColor];
    webView.opaque = NO;
    webView.scalesPageToFit = YES;

    NSString *html = [NSString stringWithFormat:
        @"<!doctype html><html><head><meta name='viewport' content='width=device-width,initial-scale=1,maximum-scale=1'>"
         "<link rel='stylesheet' href='raptor-player.css'></head><body>"
         "<div class='raptor-player'><iframe src='https://www.youtube.com/embed/%@?playsinline=1&rel=0&controls=1&modestbranding=1&vq=large' "
         "allowfullscreen></iframe></div></body></html>", video.videoID];

    [self.playerHost.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.playerHost addSubview:webView];
    NSURL *resourceBase = [NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES];
    [webView loadHTMLString:html baseURL:resourceBase];
    self.status.text = video.title;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
